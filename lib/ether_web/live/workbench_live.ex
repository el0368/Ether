defmodule EtherWeb.WorkbenchLive do
  use EtherWeb, :live_view

  alias Ether.Scanner.Utils

  @flush_interval_ms 100

  def mount(_params, _session, socket) do
    # Subscribe to filesystem deltas
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Ether.PubSub, "filetree:deltas")
    end

    sidebar_state = %{active_sidebar: "files", sidebar_visible: true}

    {:ok,
     socket
     |> assign(:page_title, "Ether")
     |> assign(:active_sidebar, sidebar_state.active_sidebar)
     |> assign(:sidebar_visible, sidebar_state.sidebar_visible)
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
    socket = 
      if socket.assigns.active_sidebar == panel do
        # Toggle visibility if clicking same panel
        assign(socket, :sidebar_visible, !socket.assigns.sidebar_visible)
      else
        # Switch to new panel and ensure visible
        socket 
        |> assign(:active_sidebar, panel)
        |> assign(:sidebar_visible, true)
      end
    {:noreply, socket}
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

  # Scanner Callbacks - Automatic Flow Control (ADR-005)
  def handle_info({:scanner_chunk, binary}, socket) do
    root = socket.assigns.root_path
    
    # Decode directly
    items = 
      Utils.decode_slab(binary, root)
      |> Enum.map(&Utils.to_ui_item(&1, root))

    # Zero Buffer: Stream immediately to DOM
    socket = 
      socket
      |> update(:file_count, &(&1 + length(items)))
      |> stream(:files, items)

    {:noreply, socket}
  end

  def handle_info({:scanner_sync, pid}, socket) do
    # Pause backend, ask Frontend for Paint Acknowledgment
    socket = 
      socket 
      |> assign(:scanner_pid, pid)
      |> push_event("flow_sync", %{})
      
    {:noreply, socket}
  end

  def handle_event("flow_ack", _params, socket) do
    # Frontend Painted. Resume Backend.
    if pid = socket.assigns[:scanner_pid] do
      send(pid, :scanner_continue)
    end
    {:noreply, socket}
  end

  def handle_info({:scanner_done, _status}, socket) do
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


end
