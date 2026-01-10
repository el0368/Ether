defmodule EtherWeb.Components.Workbench.ActivityBar do
  @moduledoc """
  The ActivityBar component - a 48px vertical icon bar for switching views.
  Follows VS Code's activitybarPart.ts architecture pattern.
  """
  use Phoenix.Component
  import EtherWeb.CoreComponents
  alias Phoenix.LiveView.JS

  attr :active_sidebar, :string, required: true

  def activity_bar(assigns) do
    ~H"""
    <div 
      id="activity-bar"
      phx-hook="SidebarControl"
      data-initial-active={@active_sidebar}
      class="w-[var(--vscode-activitybar-width)] min-w-[var(--vscode-activitybar-width)] bg-[var(--vscode-activitybar-background)] flex flex-col items-center py-2 gap-4 border-r border-[#2b2b2b]"
    >
      <div
        id="activity-icon-files"
        data-panel="files"
        class="activity-icon p-2 cursor-pointer border-l-2 text-[#858585] hover:text-white border-transparent"
        title="Explorer"
      >
        <.icon name="lucide-copy" class="w-6 h-6" />
      </div>
      <div
        id="activity-icon-search"
        data-panel="search"
        class="activity-icon p-2 cursor-pointer border-l-2 text-[#858585] hover:text-white border-transparent"
        title="Search"
      >
        <.icon name="lucide-search" class="w-6 h-6" />
      </div>
      <div
        id="activity-icon-git"
        data-panel="git"
        class="activity-icon p-2 cursor-pointer border-l-2 text-[#858585] hover:text-white border-transparent"
        title="Source Control"
      >
        <.icon name="lucide-git-branch" class="w-6 h-6" />
      </div>
      <div
        id="activity-icon-debug"
        data-panel="debug"
        class="activity-icon p-2 cursor-pointer border-l-2 text-[#858585] hover:text-white border-transparent"
        title="Run and Debug"
      >
        <.icon name="lucide-play-circle" class="w-6 h-6" />
      </div>
      <div
        id="activity-icon-extensions"
        data-panel="extensions"
        class="activity-icon p-2 cursor-pointer border-l-2 text-[#858585] hover:text-white border-transparent"
        title="Extensions"
      >
        <.icon name="lucide-layout-grid" class="w-6 h-6" />
      </div>
      <div class="mt-auto p-2 cursor-pointer text-[#858585] hover:text-white" title="Settings">
        <.icon name="lucide-settings" class="w-6 h-6" />
      </div>
    </div>
    """
  end
end
