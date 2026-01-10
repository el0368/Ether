defmodule EtherWeb.Components.Workbench.Sidebar do
  use Phoenix.Component
  import EtherWeb.CoreComponents
  alias EtherWeb.Workbench.ExplorerView

  attr :active_sidebar, :string, required: true
  attr :sidebar_visible, :boolean, required: true
  attr :workbench_layout, :map, required: true

  # Deprecated props (to be removed once logic is fully migrated)
  attr :active_file, :map, default: nil
  attr :file_count, :integer, required: true
  attr :is_loading, :boolean, required: true
  attr :files, :list, required: true

  def sidebar(assigns) do
    ~H"""
    <div 
      id="sidebar-container"
      class={[
        "bg-[var(--vscode-sidebar-background)] border-r border-[#2b2b2b] flex flex-col relative overflow-hidden transition-all duration-150",
        @sidebar_visible && "w-[var(--vscode-sidebar-width)] min-w-[var(--vscode-sidebar-width)] opacity-100",
        !@sidebar_visible && "w-0 min-w-0 opacity-0 border-none"
      ]}>
      
      <% active_container = Ether.Workbench.LayoutState.active_container(@workbench_layout) %>
      
      <div 
        id={"sidebar-panel-#{active_container.id}"} 
        class="sidebar-panel absolute inset-0 flex flex-col bg-[var(--vscode-sidebar-background)]"
      >
        <div class="px-4 flex items-center justify-between h-[35px] min-h-[35px] text-[11px] font-bold uppercase tracking-wider text-[#bbbbbb] select-none">
          <span>{active_container.label}</span>
          <div class="flex items-center gap-2">
            <.icon name="lucide-more-horizontal" class="w-4 h-4 cursor-pointer hover:bg-[#ffffff1a] rounded" />
          </div>
        </div>

        <div class="flex-1 overflow-y-auto">
          <%= if active_container.module do %>
            <%= if active_container.id == "files" do %>
              <.live_component
                module={active_container.module}
                id="explorer-view"
                files={@files}
                active_file={@active_file}
                file_count={@file_count}
                is_loading={@is_loading}
              />
            <% else %>
              <.live_component
                module={active_container.module}
                id={"sidebar-#{active_container.id}"}
              />
            <% end %>
          <% else %>
             <div class="flex-1 flex items-center justify-center text-[12px] text-[#858585] italic">
               {active_container.label} functionality coming soon...
             </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
