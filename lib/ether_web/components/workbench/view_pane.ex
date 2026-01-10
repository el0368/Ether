defmodule EtherWeb.Workbench.ViewPane do
  use Phoenix.Component
  import EtherWeb.CoreComponents

  @moduledoc """
  A single collapsible pane within a Side Bar or Panel.
  """

  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :expanded, :boolean, default: true
  attr :component, :atom, default: nil
  attr :component_assigns, :map, default: %{}

  def view_pane(assigns) do
    ~H"""
    <div
      class="view-pane flex flex-col border-t border-[#454545] first:border-t-0"
      x-data={"{ expanded: #{@expanded} }"}
    >
      <%!-- Header --%>
      <div
        class="pane-header group flex items-center px-[4px] h-[22px] min-h-[22px] cursor-pointer bg-[#252526] focus:outline-none"
        @click="expanded = !expanded"
        tabindex="0"
      >
        <div
          class="mr-[2px] transition-transform duration-100 flex items-center justify-center p-0.5"
          x-bind:class="expanded && 'rotate-90'"
        >
          <.icon name="lucide-chevron-right" class="w-4 h-4 text-[#cccccc]" />
        </div>
        
        <span class="text-[11px] font-bold text-[#cccccc] uppercase truncate select-none">
          {@title}
        </span>
        <div class="flex-1"></div>
         <%!-- Pane Actions (e.g. New File, Refresh) - Visible on Hover --%>
        <div class="pane-actions flex opacity-0 group-hover:opacity-100 items-center pr-2">
          <%!-- Actions will be injected here --%>
        </div>
      </div>
       <%!-- Body --%>
      <div class="pane-body overflow-hidden" x-show="expanded" x-collapse>
        <%= if @component do %>
          <.live_component module={@component} id={"pane-content-#{@id}"} {@component_assigns} />
        <% else %>
          <div class="p-4 text-xs italic text-gray-500">No content component.</div>
        <% end %>
      </div>
    </div>
    """
  end
end
