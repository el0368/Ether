defmodule EtherWeb.WorkbenchLive do
  use EtherWeb, :live_view
  import LiveSvelte

  alias Ether.Scanner.Utils
  alias Ether.Workbench.LayoutState
  alias Ether.Workbench.Storage

  @flush_interval_ms 100

  def mount(_params, _session, socket) do
    # Subscribe to filesystem deltas
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Ether.PubSub, "filetree:deltas")
    end

    layout = Storage.load()

    {:ok,
     socket
     |> assign(:page_title, "Ether")
     |> assign(:workbench_layout, layout)
     |> assign(:active_sidebar, layout.active_id)
     |> assign(:sidebar_visible, layout.visible)
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
     |> assign(:context_menu, nil)
     |> assign(:editor_content, "")
     |> assign(:files_list, [])
     |> stream(:files, [])}
  end

  def handle_event("show_context_menu", %{"panel" => _panel, "x" => x, "y" => y}, socket) do
    # VS Code behavior: show ALL views with checkmarks
    all_views = Registry.all()
    pinned_ids = socket.assigns.workbench_layout.pinned_ids

    items =
      all_views
      |> Enum.map(fn view ->
        is_pinned = view.id in pinned_ids

        %{
          label: view.label,
          checked: is_pinned,
          action:
            JS.push(if(is_pinned, do: "unpin_view", else: "pin_view"), value: %{panel: view.id})
        }
      end)
      |> Enum.concat([
        :separator,
        %{label: "Reset Activity Bar", action: JS.push("reset_layout")}
      ])

    {:noreply, assign(socket, :context_menu, %{x: x, y: y, items: items})}
  end

  def handle_event("show_context_menu", %{"panel" => panel}, socket) do
    # Fallback for when coordinates aren't sent from basic phx-click
    handle_event("show_context_menu", %{"panel" => panel, "x" => 50, "y" => 100}, socket)
  end

  def handle_event("close_context_menu", _params, socket) do
    {:noreply, assign(socket, :context_menu, nil)}
  end

  def handle_event("unpin_view", %{"panel" => panel}, socket) do
    layout = LayoutState.unpin_view(socket.assigns.workbench_layout, panel)
    Storage.save(layout)

    {:noreply,
     socket
     |> assign(:workbench_layout, layout)
     |> assign(:context_menu, nil)}
  end

  def handle_event("reset_layout", _params, socket) do
    layout = LayoutState.reset()
    Storage.save(layout)

    {:noreply,
     socket
     |> assign(:workbench_layout, layout)
     |> assign(:active_sidebar, layout.active_id)
     |> assign(:sidebar_visible, layout.visible)
     |> assign(:context_menu, nil)}
  end

  def handle_event("pin_view", %{"panel" => panel}, socket) do
    layout = LayoutState.pin_view(socket.assigns.workbench_layout, panel)
    Storage.save(layout)

    {:noreply,
     socket
     |> assign(:workbench_layout, layout)
     |> assign(:context_menu, nil)}
  end

  def handle_event("reorder_icons", %{"panel" => panel, "to_index" => to_index}, socket) do
    layout = LayoutState.reorder_views(socket.assigns.workbench_layout, panel, to_index)
    Storage.save(layout)
    {:noreply, assign(socket, :workbench_layout, layout)}
  end

  def handle_event("toggle_sidebar", _params, socket) do
    layout = %{
      socket.assigns.workbench_layout
      | visible: !socket.assigns.workbench_layout.visible
    }

    Storage.save(layout)

    {:noreply,
     socket
     |> assign(:workbench_layout, layout)
     |> assign(:sidebar_visible, layout.visible)}
  end

  def handle_event("set_sidebar", %{"panel" => panel}, socket) do
    layout = LayoutState.toggle_view(socket.assigns.workbench_layout, panel)
    Storage.save(layout)

    {:noreply,
     socket
     |> assign(:workbench_layout, layout)
     |> assign(:active_sidebar, layout.active_id)
     |> assign(:sidebar_visible, layout.visible)}
  end

  def handle_event("toggle_panel", _params, socket) do
    {:noreply, assign(socket, :panel_visible, !socket.assigns.panel_visible)}
  end

  # Handle "Open Folder" with path from Tauri dialog
  def handle_event("open_folder_path", %{"path" => path}, socket) do
    Ether.Scanner.scan_async(path, [".git", "node_modules", "_build", "deps"], 2)

    {:noreply,
     socket
     |> assign(:isLoading, true)
     |> assign(:root_path, path)
     |> assign(:files_list, [])}
  end

  # Handle "Open Folder" fallback (triggered by UI button without Tauri)
  def handle_event("open_folder", _params, socket) do
    # Scan the current directory as fallback
    path = socket.assigns.root_path || File.cwd!()
    Ether.Scanner.scan_async(path, [".git", "node_modules", "_build", "deps"], 2)

    {:noreply,
     socket
     |> assign(:isLoading, true)
     |> assign(:root_path, path)
     |> assign(:files_list, [])}
  end

  def handle_event("refresh_folder", _params, socket) do
    if path = socket.assigns.root_path do
      Ether.Scanner.scan_async(path, [".git", "node_modules", "_build", "deps"], 2)
      {:noreply, socket |> assign(:isLoading, true) |> assign(:files_list, [])}
    else
      {:noreply, socket}
    end
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
            |> assign(:editor_content, content)
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

  # Handle editor content changes from Monaco
  def handle_event("editor_change", %{"text" => text}, socket) do
    # Store the editor content for potential save operations
    {:noreply, assign(socket, :editor_content, text)}
  end

  def handle_event("flow_ack", _params, socket) do
    # Frontend Painted. Resume Backend.
    if pid = socket.assigns[:scanner_pid] do
      send(pid, :scanner_continue)
    end

    {:noreply, socket}
  end

  # Scanner Callbacks - Automatic Flow Control (ADR-005)
  def handle_info({:scanner_chunk, binary}, socket) do
    root = socket.assigns.root_path

    # Decode directly
    items =
      Utils.decode_slab(binary, root)
      |> Enum.map(&Utils.to_ui_item(&1, root))

    # Prop-Bridge: Update files_list for Svelte
    socket =
      socket
      |> update(:file_count, &(&1 + length(items)))
      |> update(:files_list, &(&1 ++ items))
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
        # Re-open for now
        {:noreply, assign(socket, :quick_pick_visible, true)}

      "toggle_sidebar" ->
        {:noreply, assign(socket, :sidebar_visible, !socket.assigns.sidebar_visible)}

      _ ->
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
end
