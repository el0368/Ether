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
    <div class="w-[var(--vscode-sidebar-width)] min-w-[var(--vscode-sidebar-width)] bg-[var(--vscode-sidebar-background)] border-r border-[#2b2b2b] flex flex-col">
      <%!-- Files Panel (Always Rendered, Hidden via CSS) --%>
      <div class={"flex-1 flex flex-col min-h-0 overflow-hidden #{if @active_sidebar != "files", do: "hidden"}"}>
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
      <div class={"flex-1 flex flex-col min-h-0 #{if @active_sidebar != "search", do: "hidden"}"}>
        <div class="title px-5 flex items-center h-[35px] min-h-[35px] text-[11px] font-normal uppercase tracking-wide text-[#cccccc] select-none">
          Search
        </div>
        <div class="flex-1 flex items-center justify-center text-[12px] text-[#858585] italic">
          Search functionality coming soon...
        </div>
      </div>

      <%!-- Git Panel --%>
      <div class={"flex-1 flex flex-col min-h-0 #{if @active_sidebar != "git", do: "hidden"}"}>
        <div class="title px-5 flex items-center h-[35px] min-h-[35px] text-[11px] font-normal uppercase tracking-wide text-[#cccccc] select-none">
          Source Control
        </div>
        <div class="flex-1 flex items-center justify-center text-[12px] text-[#858585] italic">
          Git integration coming soon...
        </div>
      </div>
      
      <%!-- Debug Panel --%>
      <div class={"flex-1 flex flex-col min-h-0 #{if @active_sidebar != "debug", do: "hidden"}"}>
        <div class="title px-5 flex items-center h-[35px] min-h-[35px] text-[11px] font-normal uppercase tracking-wide text-[#cccccc] select-none">
          Run and Debug
        </div>
        <div class="flex-1 flex items-center justify-center text-[12px] text-[#858585] italic">
          Debug configuration coming soon...
        </div>
      </div>
      
      <%!-- Extensions Panel --%>
      <div class={"flex-1 flex flex-col min-h-0 #{if @active_sidebar != "extensions", do: "hidden"}"}>
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
