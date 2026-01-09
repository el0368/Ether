defmodule EtherWeb.WorkbenchLive do
  use EtherWeb, :live_view

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
     |> assign(:root_path, File.cwd!())
     |> assign(:isLoading, false)
     |> assign(:file_count, 0)
     |> stream(:files, [])}
  end

  # Handle "Open Folder" equivalent (triggered by UI button)
  def handle_event("open_folder", _params, socket) do
    # In a real desktop app, we'd trigger a native dialog here.
    # For now, we scan the current directory.
    path = socket.assigns.root_path
    Ether.Scanner.scan_raw(path)
    
    {:noreply, socket |> assign(:isLoading, true)}
  end

  def handle_event("select_file", %{"path" => path}, socket) do
    if not File.dir?(path) do
      case Ether.Agents.FileServerAgent.read_file(path) do
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

  # Scanner Callbacks
  def handle_info({:scanner_chunk, binary}, socket) do
    root = socket.assigns.root_path
    items = 
      decode_slab(binary, root, [])
      |> Enum.map(&Ether.Explorer.process_scan_item(&1, root))

    socket = 
      socket
      |> update(:file_count, &(&1 + length(items)))
      |> stream(:files, items)

    {:noreply, socket}
  end

  def handle_info({:scanner_done, _status}, socket) do
    {:noreply, assign(socket, :isLoading, false)}
  end

  def handle_info({:scanner_error, reason}, socket) do
    # Handle error...
    {:noreply, assign(socket, :isLoading, false)}
  end

  # File Delta Support (Watcher)
  def handle_info({:file_delta, %{path: path, type: type}}, socket) do
    root = socket.assigns.root_path
    item = Ether.Explorer.process_scan_item({path, type}, root)
    
    # LiveView streams handle updates automatically by ID
    {:noreply, stream(socket, :files, [item])}
  end

  # Helper copied from Scanner (private or shared later)
  defp decode_slab(<<>>, _root, acc), do: Enum.reverse(acc)
  defp decode_slab(<<type::8, len::16-little, path_bin::binary-size(len), rest::binary>>, root, acc) do
    rel_path = String.to_charlist(path_bin) |> List.to_string()
    abs_path = Path.join(root, rel_path)
    type_atom = if type == 2, do: :directory, else: :file
    decode_slab(rest, root, [{abs_path, type_atom} | acc])
  end
  defp decode_slab(rest, _root, acc), do: Enum.reverse(acc)
end
