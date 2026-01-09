defmodule EtherWeb.WorkbenchLive do
  use EtherWeb, :live_view

  alias Ether.Scanner.Utils

  @flush_interval_ms 100

  def mount(_params, _session, socket) do
    # Subscribe to filesystem deltas
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Ether.PubSub, "filetree:deltas")
    end

    {:ok,
     socket
     |> assign(:page_title, "Ether")
     |> assign(:active_sidebar, "files")
     |> assign(:sidebar_visible, true)
     |> assign(:panel_visible, false)
     |> assign(:active_file, nil)
     |> assign(:recent_files, [])
     |> assign(:root_path, nil)
     |> assign(:isLoading, false)
     |> assign(:file_count, 0)
     |> assign(:scan_buffer, [])
     |> assign(:flush_pending, false)
     |> assign(:quick_pick_visible, false)
     |> assign(:quick_pick_mode, "files")
     |> stream(:files, [])}
  end

  def handle_event("toggle_sidebar", _params, socket) do
    {:noreply, assign(socket, :sidebar_visible, !socket.assigns.sidebar_visible)}
  end

  def handle_event("set_sidebar", %{"panel" => panel}, socket) do
    # If clicking the same panel that is already active
    if socket.assigns.active_sidebar == panel do
      # Toggle visibility
      {:noreply, assign(socket, :sidebar_visible, !socket.assigns.sidebar_visible)}
    else
      # Switch to new panel and ensure visible
      {:noreply, 
       socket
       |> assign(:active_sidebar, panel)
       |> assign(:sidebar_visible, true)}
    end
  end

  def handle_event("toggle_panel", _params, socket) do
    {:noreply, assign(socket, :panel_visible, !socket.assigns.panel_visible)}
  end

  # Handle "Open Folder" equivalent (triggered by UI button)
  def handle_event("open_folder", _params, socket) do
    # In a real desktop app, we'd trigger a native dialog here.
    # For now, we scan the current directory.
    # For now, we scan the current directory.
    path = socket.assigns.root_path || File.cwd!()
    Ether.Scanner.scan_async(path, [".git", "node_modules", "_build", "deps"], 2)
    
    {:noreply, socket |> assign(:isLoading, true) |> assign(:root_path, path)}
  end

  def handle_event("open_quick_pick", params, socket) do
    mode = Map.get(params, "mode", "files")
    {:noreply, 
     socket 
     |> assign(:quick_pick_visible, true)
     |> assign(:quick_pick_mode, mode)}
  end

  def handle_event("close_quick_pick", _params, socket) do
    {:noreply, assign(socket, :quick_pick_visible, false)}
  end

  def handle_event("execute_command", %{"id" => id}, socket) do
    handle_command_execution(id, socket)
  end

  def handle_event("select_file", %{"path" => path}, socket) do
    if not File.dir?(path) do
      case File.read(path) do
        {:ok, content} ->
          socket = 
            socket
            |> assign(:active_file, %{name: Path.basename(path), path: path})
            |> push_event("load_file", %{
              text: content,
              language: get_language(path),
              path: path
            })
          {:noreply, socket}
        {:error, _reason} ->
          {:noreply, socket}
      end
    else
      # TODO: Handle folder expansion toggle
      {:noreply, socket}
    end
  end

  defp get_language(path) do
    case Path.extname(path) do
      ext when ext in [".ex", ".exs"] -> "elixir"
      ".heex" -> "html"
      ".js" -> "javascript"
      ".ts" -> "typescript"
      ".svelte" -> "html"
      ".css" -> "css"
      ".json" -> "json"
      ".md" -> "markdown"
      ".zig" -> "zig"
      _ -> "text"
    end
  end

  # Scanner Callbacks - Buffered for UI Performance
  def handle_info({:scanner_chunk, binary}, socket) do
    root = socket.assigns.root_path
    
    # Decode with optimized Utils
    items = 
      Utils.decode_slab(binary, root)
      |> Enum.map(&Utils.to_ui_item(&1, root))

    # Buffer items instead of immediate UI update
    buffer = socket.assigns.scan_buffer ++ items
    
    # Schedule a flush if not already pending
    socket = 
      if socket.assigns.flush_pending do
        assign(socket, :scan_buffer, buffer)
      else
        Process.send_after(self(), :flush_scan_buffer, @flush_interval_ms)
        socket
        |> assign(:scan_buffer, buffer)
        |> assign(:flush_pending, true)
      end

    {:noreply, socket}
  end

  # Flush buffered items to the UI stream (Chunked for UI Stability)
  def handle_info(:flush_scan_buffer, socket) do
    all_items = socket.assigns.scan_buffer
    {to_stream, remaining} = Enum.split(all_items, 200)
    
    socket = 
      socket
      |> update(:file_count, &(&1 + length(to_stream)))
      |> stream(:files, to_stream)
      |> assign(:scan_buffer, remaining)

    socket = 
      if remaining != [] do
        Process.send_after(self(), :flush_scan_buffer, @flush_interval_ms)
        assign(socket, :flush_pending, true)
      else
        assign(socket, :flush_pending, false)
      end

    {:noreply, socket}
  end

  def handle_info({:scanner_done, _status}, socket) do
    # Final flush of any remaining items
    socket = flush_remaining_buffer(socket)
    {:noreply, assign(socket, :isLoading, false)}
  end

  def handle_info({:scanner_error, _reason}, socket) do
    {:noreply, assign(socket, :isLoading, false)}
  end

  # File Delta Support (Watcher)
  def handle_info({:file_delta, %{path: path, type: type}}, socket) do
    root = socket.assigns.root_path
    item = Utils.to_ui_item({path, type}, root)
    {:noreply, stream(socket, :files, [item])}
  end

  def handle_info({:execute_command, id}, socket) do
    handle_command_execution(id, socket)
  end

  def handle_info({:close_quick_pick, _}, socket) do
    {:noreply, assign(socket, :quick_pick_visible, false)}
  end
  
  def handle_info({:select_file, %{"path" => path}}, socket) do
     # Reuse existing logic via self-send or duplicate logic
     handle_event("select_file", %{"path" => path}, socket)
  end

  defp handle_command_execution(id, socket) do
    socket = assign(socket, :quick_pick_visible, false)
    
    case id do
      "show_commands" ->
        {:noreply, assign(socket, :quick_pick_visible, true)} # Re-open for now
      
      "toggle_sidebar" -> 
        {:noreply, assign(socket, :sidebar_visible, !socket.assigns.sidebar_visible)}
      
      _ ->
        {:noreply, socket}
    end
  end

  defp flush_remaining_buffer(socket) do
    buffer = socket.assigns.scan_buffer
    if buffer == [] do
      socket
    else
      socket
      |> update(:file_count, &(&1 + length(buffer)))
      |> stream(:files, buffer)
      |> assign(:scan_buffer, [])
      |> assign(:flush_pending, false)
    end
  end
end
