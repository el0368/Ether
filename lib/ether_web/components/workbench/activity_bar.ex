defmodule EtherWeb.Components.Workbench.ActivityBar do
  @moduledoc """
  The ActivityBar component - a 48px vertical icon bar for switching views.
  Follows VS Code's activitybarPart.ts architecture pattern.
  """
  use Phoenix.Component
  import EtherWeb.CoreComponents
  alias Phoenix.LiveView.JS

  attr :active_sidebar, :string, required: true
  attr :sidebar_visible, :boolean, required: true
  attr :pinned_containers, :list, required: true

  def activity_bar(assigns) do
    ~H"""
    <div 
      id="activity-bar"
      phx-hook="ActivityBarSort"
      data-active-sidebar={@active_sidebar}
      data-sidebar-visible={"#{@sidebar_visible}"}
      class="w-[var(--vscode-activitybar-width)] min-w-[var(--vscode-activitybar-width)] bg-[var(--vscode-activitybar-background)] flex flex-col items-center py-2 gap-4 border-r border-[#2b2b2b]"
    >
      <%= for container <- @pinned_containers do %>
        <.nav_item 
          id={"activity-icon-#{container.id}"} 
          panel={container.id} 
          title={container.label} 
          icon={container.icon} 
          active={@active_sidebar == container.id} 
        />
      <% end %>
      <div class="mt-auto p-2 cursor-pointer text-[#858585] hover:text-white" title="Settings">
        <.icon name="lucide-settings" class="w-6 h-6" />
      </div>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :panel, :string, required: true
  attr :title, :string, required: true
  attr :icon, :string, required: true
  attr :active, :boolean, required: true

  defp nav_item(assigns) do
    ~H"""
    <div
      id={@id}
      data-panel={@panel}
      draggable="true"
      class={[
        "activity-icon p-2 cursor-pointer border-l-2 hover:text-white",
        @active && "text-white opacity-100 border-white active",
        !@active && "text-[#858585] border-transparent"
      ]}
      title={@title}
    >
      <.icon name={@icon} class="w-6 h-6" />
    </div>
    """
  end
end
