defmodule EtherWeb.Workbench.ViewMenuActions do
  use EtherWeb, :live_component
  import EtherWeb.CoreComponents

  @moduledoc """
  Renders the "..." contextual menu for View Containers.
  """

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative">
      <div
        class="cursor-pointer hover:text-white flex items-center justify-center w-5 h-5"
        title="More Actions..."
        phx-click="toggle_menu"
        phx-target={@myself}
      >
        <.icon name="lucide-more-horizontal" class="w-4 h-4" />
      </div>
      
      <%= if @menu_visible do %>
        <div class="absolute right-0 top-full mt-1 w-48 bg-[#252526] border border-[#454545] shadow-xl z-50 rounded-sm py-1">
          <div
            class="px-3 py-1 hover:bg-[#04395e] hover:text-white cursor-pointer text-xs flex items-center"
            phx-click="hide_side_bar"
            phx-target={@myself}
          >
            <span>Hide Side Bar</span>
            <div class="flex-1"></div>
             <span class="opacity-70 ml-2"></span>
          </div>
          
          <div class="h-[1px] bg-[#454545] my-1"></div>
          
          <div class="px-3 py-1 text-[10px] uppercase opacity-50 select-none">Views</div>
          
          <%= for pane <- @panes do %>
            <div
              class="px-3 py-1 hover:bg-[#04395e] hover:text-white cursor-pointer text-xs flex items-center"
              phx-click="toggle_pane"
              phx-value-id={pane.id}
              phx-target={@myself}
            >
              <div class={"w-4 mr-1 flex items-center justify-center #{if !pane.expanded, do: "invisible"}"}>
                <.icon name="lucide-check" class="w-3 h-3" />
              </div>
               <span>{pane.title}</span>
            </div>
          <% end %>
        </div>
         <%!-- click outside handler --%>
        <div class="fixed inset-0 z-40 bg-transparent" phx-click="toggle_menu" phx-target={@myself}>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:menu_visible, false)}
  end

  @impl true
  def handle_event("toggle_menu", _params, socket) do
    {:noreply, update(socket, :menu_visible, &(!&1))}
  end

  @impl true
  def handle_event("hide_side_bar", _params, socket) do
    send(self(), {:toggle_sidebar, nil})
    {:noreply, assign(socket, :menu_visible, false)}
  end

  # TODO: Implement toggle_pane logic in parent
end
