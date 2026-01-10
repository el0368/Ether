defmodule EtherWeb.Components.Workbench.ContextMenu do
  @moduledoc """
  A floating context menu component.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :x, :integer, required: true
  attr :y, :integer, required: true
  attr :items, :list, required: true
  attr :on_close, :string, default: "close_context_menu"

  def context_menu(assigns) do
    ~H"""
    <div
      id="context-menu-overlay"
      class="fixed inset-0 z-50"
      phx-click={@on_close}
      phx-window-keydown={@on_close}
      phx-key="escape"
    >
      <div
        class="absolute bg-[#252526] border border-[#454545] py-1 shadow-xl min-w-[160px] text-[12px] text-[#cccccc] rounded"
        style={"top: #{@y}px; left: #{@x}px;"}
      >
        <%= for item <- @items do %>
          <%= if item == :separator do %>
            <div class="h-[1px] bg-[#454545] my-1 mx-1"></div>
          <% else %>
            <div
              class="px-4 py-1 hover:bg-[#094771] hover:text-white cursor-pointer flex items-center justify-between group"
              phx-click={item.action}
            >
              <span>{item.label}</span>
              <%= if Map.get(item, :checked) do %>
                <EtherWeb.CoreComponents.icon name="lucide-check" class="w-3 h-3" />
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end
end
