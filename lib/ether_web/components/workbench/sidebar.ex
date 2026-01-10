defmodule EtherWeb.Components.Workbench.Sidebar do
  use Phoenix.Component
  import EtherWeb.CoreComponents
  alias EtherWeb.Workbench.ExplorerView

  attr :active_sidebar, :string, required: true
  attr :active_file, :map, default: nil
  attr :file_count, :integer, required: true
  attr :is_loading, :boolean, required: true
  attr :files, :list, required: true

  def sidebar(assigns) do
    ~H"""
    <div class="w-[var(--vscode-sidebar-width)] min-w-[var(--vscode-sidebar-width)] bg-[var(--vscode-sidebar-background)] border-r border-[#2b2b2b] flex flex-col relative overflow-hidden">
      <%!-- Files Panel --%>
      <div id="sidebar-panel-files" class="sidebar-panel absolute inset-0 flex flex-col bg-[var(--vscode-sidebar-background)] transition-transform duration-0 -translate-x-full invisible">
        <div class="title px-5 flex items-center h-[35px] min-h-[35px] text-[11px] font-normal uppercase tracking-wide text-[#cccccc] select-none">
          Explorer
        </div>
        <div class="flex-1 overflow-y-auto">
          <.live_component
            module={ExplorerView}
            id="explorer-view"
            files={@files}
            active_file={@active_file}
            file_count={@file_count}
            is_loading={@is_loading}
          />
        </div>
      </div>

      <%!-- Search Panel --%>
      <div id="sidebar-panel-search" class="sidebar-panel absolute inset-0 flex flex-col bg-[var(--vscode-sidebar-background)] transition-transform duration-0 -translate-x-full invisible">
        <div class="title px-5 flex items-center h-[35px] min-h-[35px] text-[11px] font-normal uppercase tracking-wide text-[#cccccc] select-none">
          Search
        </div>
        <div class="flex-1 flex items-center justify-center text-[12px] text-[#858585] italic">
          Search functionality coming soon...
        </div>
      </div>

      <%!-- Git Panel --%>
      <div id="sidebar-panel-git" class="sidebar-panel absolute inset-0 flex flex-col bg-[var(--vscode-sidebar-background)] transition-transform duration-0 -translate-x-full invisible">
        <div class="title px-5 flex items-center h-[35px] min-h-[35px] text-[11px] font-normal uppercase tracking-wide text-[#cccccc] select-none">
          Source Control
        </div>
        <div class="flex-1 flex items-center justify-center text-[12px] text-[#858585] italic">
          Git integration coming soon...
        </div>
      </div>
      
      <%!-- Debug Panel --%>
      <div id="sidebar-panel-debug" class="sidebar-panel absolute inset-0 flex flex-col bg-[var(--vscode-sidebar-background)] transition-transform duration-0 -translate-x-full invisible">
        <div class="title px-5 flex items-center h-[35px] min-h-[35px] text-[11px] font-normal uppercase tracking-wide text-[#cccccc] select-none">
          Run and Debug
        </div>
        <div class="flex-1 flex items-center justify-center text-[12px] text-[#858585] italic">
          Debug configuration coming soon...
        </div>
      </div>
      
      <%!-- Extensions Panel --%>
      <div id="sidebar-panel-extensions" class="sidebar-panel absolute inset-0 flex flex-col bg-[var(--vscode-sidebar-background)] transition-transform duration-0 -translate-x-full invisible">
        <div class="title px-5 flex items-center h-[35px] min-h-[35px] text-[11px] font-normal uppercase tracking-wide text-[#cccccc] select-none">
          Extensions
        </div>
        <div class="flex-1 flex items-center justify-center text-[12px] text-[#858585] italic">
          Extension marketplace coming soon...
        </div>
      </div>
    </div>
    """
  end
end
