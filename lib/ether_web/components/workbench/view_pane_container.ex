defmodule EtherWeb.Workbench.ViewPaneContainer do
  use Phoenix.Component
  import EtherWeb.Workbench.ViewPane

  @moduledoc """
  Manages a vertical list of collapsible ViewPanes.
  """

  attr :title, :string, required: true
  attr :panes, :list, required: true
  attr :id, :string, required: true

  def view_pane_container(assigns) do
    ~H"""
    <div class="h-full flex flex-col min-h-0 bg-[#252526]">
      <div class="title px-5 flex items-center h-[35px] min-h-[35px] text-[11px] font-normal uppercase tracking-wide text-[#cccccc] select-none">
        {@title}
        <div class="flex-1"></div>
         <%!-- View Container Menu Actions --%>
        <div class="actions flex items-center">
          <div
            class="codicon codicon-ellipsis cursor-pointer hover:text-white text-[13px]"
            title="More Actions..."
          >
          </div>
        </div>
      </div>
      
      <div class="pane-body flex-1 overflow-y-auto">
        <%= for pane <- @panes do %>
          <.view_pane
            id={pane.id}
            title={pane.title}
            expanded={pane.expanded}
            component={pane.component}
            component_assigns={pane.assigns || %{}}
          />
        <% end %>
      </div>
    </div>
    """
  end
end
