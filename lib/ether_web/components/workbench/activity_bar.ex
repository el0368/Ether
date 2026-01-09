defmodule EtherWeb.Components.Workbench.ActivityBar do
  @moduledoc """
  The ActivityBar component - a 48px vertical icon bar for switching views.
  Follows VS Code's activitybarPart.ts architecture pattern.
  """
  use Phoenix.Component
  import EtherWeb.CoreComponents

  attr :active_sidebar, :string, required: true

  def activity_bar(assigns) do
    ~H"""
    <div class="w-[var(--vscode-activitybar-width)] min-w-[var(--vscode-activitybar-width)] bg-[var(--vscode-activitybar-background)] flex flex-col items-center py-2 gap-4 border-r border-[#2b2b2b]">
      <div
        phx-click="set_sidebar"
        phx-value-panel="files"
        class={"p-2 cursor-pointer transition-colors duration-200 border-l-2 #{if @active_sidebar == "files", do: "text-white opacity-100 border-white", else: "text-[#858585] hover:text-white border-transparent"}"}
        title="Explorer"
      >
        <.icon name="hero-document-duplicate" class="w-6 h-6" />
      </div>
      <div
        phx-click="set_sidebar"
        phx-value-panel="search"
        class={"p-2 cursor-pointer transition-colors duration-200 border-l-2 #{if @active_sidebar == "search", do: "text-white border-white", else: "text-[#858585] hover:text-white border-transparent"}"}
        title="Search"
      >
        <.icon name="hero-magnifying-glass" class="w-6 h-6" />
      </div>
      <div
        phx-click="set_sidebar"
        phx-value-panel="git"
        class={"p-2 cursor-pointer transition-colors duration-200 border-l-2 #{if @active_sidebar == "git", do: "text-white border-white", else: "text-[#858585] hover:text-white border-transparent"}"}
        title="Source Control"
      >
        <.icon name="hero-command-line" class="w-6 h-6" />
      </div>
      <div class="mt-auto p-2 cursor-pointer text-[#858585] hover:text-white" title="Settings">
        <.icon name="hero-cog-6-tooth" class="w-6 h-6" />
      </div>
    </div>
    """
  end
end
