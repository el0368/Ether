defmodule EtherWeb.Workbench.QuickPick do
  use EtherWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id="quick-pick-overlay"
      class="fixed inset-0 z-50 flex justify-center pt-[6px]"
      role="dialog"
      aria-modal="true"
      phx-window-keydown="close_quick_pick"
      phx-key="escape"
    >
      <!-- Backdrop (optional, VS Code strictly doesn't have a dark backdrop but clicks outside close it) -->
      <div
        class="absolute inset-0 bg-transparent"
        phx-click="close_quick_pick"
      >
      </div>
      <!-- Quick Pick Widget -->
      <div class="relative w-[600px] flex flex-col bg-[#252526] shadow-xl rounded-md overflow-hidden border border-[#454545] text-[#cccccc]">
        <!-- Input Area -->
        <div class="flex items-center px-1 py-1 bg-[#3c3c3c]">
          <input
            type="text"
            id="quick-pick-input"
            class="w-full bg-[#3c3c3c] text-white border border-[#3c3c3c] focus:outline-none focus:border-[#007fd4] px-2 h-7 text-sm placeholder-[#cccccc]"
            placeholder="Type a command or search files..."
            phx-keyup="search"
            phx-target={@myself}
            autocomplete="off"
            autofocus
          />
        </div>
        <!-- List Area -->
        <div class="max-h-[300px] overflow-y-auto py-1">
          <%= for item <- @items do %>
            <div
              class={"flex items-center px-3 py-1 cursor-pointer hover:bg-[#2a2d2e] #{if item.active, do: "bg-[#04395e] text-white", else: ""}"}
              phx-click="execute_command"
              phx-value-id={item.id}
              phx-target={@myself}
            >
              <div class="flex flex-col">
                <span class="text-sm font-medium">{item.label}</span>
                <%= if item.description do %>
                  <span class="text-xs opacity-70">{item.description}</span>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    mode = Map.get(assigns, :mode, "files")

    initial_items =
      case mode do
        "commands" -> default_commands()
        # Wait for input or show recents?
        "files" -> []
        _ -> []
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:mode, mode)
     |> assign(:items, initial_items)}
  end

  @impl true
  def handle_event("search", %{"value" => query}, socket) do
    items =
      case socket.assigns.mode do
        "commands" -> filter_commands(query)
        "files" -> search_files(query)
      end

    {:noreply, assign(socket, items: items)}
  end

  @impl true
  def handle_event("execute_command", %{"id" => id}, socket) do
    if socket.assigns.mode == "files" do
      send(self(), {:select_file, %{"path" => id}})
      # Close explicitly
      send(self(), {:close_quick_pick, nil})
    else
      send(self(), {:execute_command, id})
    end

    {:noreply, socket}
  end

  defp default_commands do
    [
      %{
        id: "show_commands",
        label: "Show All Commands",
        description: "Ctrl+Shift+P",
        active: true
      },
      %{id: "go_to_file", label: "Go to File...", description: "Ctrl+P", active: false},
      %{
        id: "toggle_sidebar",
        label: "View: Toggle Primary Side Bar Visibility",
        description: "Ctrl+B",
        active: false
      }
    ]
  end

  defp filter_commands("") do
    default_commands()
  end

  defp filter_commands(query) do
    default_commands()
    |> Enum.filter(fn item ->
      String.contains?(String.downcase(item.label), String.downcase(query))
    end)
  end

  defp search_files("") do
    # TODO: Show recent files
    []
  end

  defp search_files(query) do
    case Ether.Agents.FileServerAgent.find_files(query) do
      # Limit to 20
      {:ok, files} -> files |> Enum.take(20)
      _ -> []
    end
  end
end
