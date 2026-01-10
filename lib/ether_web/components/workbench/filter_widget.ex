defmodule EtherWeb.Workbench.FilterWidget do
  use EtherWeb, :live_component
  import EtherWeb.CoreComponents

  @moduledoc """
  Standardized Filter/Search Widget for View Panes.
  """

  @impl true
  def render(assigns) do
    ~H"""
    <div class="filter-widget relative flex items-center bg-[#252526] mb-1">
      <div class="h-full flex-1 flex items-center border border-[#3c3c3c] focus-within:border-[#007fd4] bg-[#3c3c3c]">
        <input
          type="text"
          placeholder={@placeholder}
          class="w-full h-[20px] bg-transparent border-none text-[12px] text-[#cccccc] placeholder-[#cccccc] focus:outline-none px-1"
          phx-keyup="filter"
          phx-target={@myself}
        />
        <div class="actions flex items-center pr-1">
          <div
            class="w-4 h-4 cursor-pointer hover:text-white flex items-center justify-center"
            title="Filter"
          >
            <.icon name="lucide-filter" class="w-3 h-3" />
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("filter", %{"value" => _query}, socket) do
    # Placeholder for filter logic
    {:noreply, socket}
  end
end
