defmodule EtherWeb.Workbench.ExplorerView do
  use EtherWeb, :live_component

  @moduledoc """
  The actual File Explorer Tree View.
  Intended to be hosted inside a ViewPane.
  """

  @impl true
  def render(assigns) do
    active_path = if assigns.active_file, do: assigns.active_file.path, else: ""
    assigns = assign(assigns, :active_path, active_path)

    ~H"""
    <div class="h-full flex flex-col overflow-hidden">
      <div id="file-tree" phx-update="stream" class="w-full">
        <div
          :for={{id, file} <- @files}
          id={id}
          data-path={file.path}
          class={"file-item group flex items-center pr-2 cursor-pointer hover:bg-[#2a2d2e] select-none text-[13px] leading-[22px] #{if file.path == @active_path, do: "bg-[#37373d]", else: ""}"}
          style={"padding-left: #{file.depth * 12 + 8}px"}
          phx-click="select_file"
          phx-value-path={file.path}
        >
          <div class="flex items-center gap-1.5 w-full overflow-hidden">
            <%= if file.is_dir do %>
              <!-- Chevron -->
              <svg viewBox="0 0 24 24" fill="currentColor" class={"w-3.5 h-3.5 text-[#858585] transition-transform #{if file.expanded, do: "rotate-90", else: ""}"}>
                <path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/>
              </svg>
              <!-- Folder Icon -->
              <svg viewBox="0 0 24 24" fill="currentColor" class="w-4 h-4 text-[#858585]">
                <path d="M10 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2h-8l-2-2z"/>
              </svg>
            <% else %>
              <div class="w-3.5"></div>
              <!-- File Icon -->
              <svg viewBox="0 0 24 24" fill="currentColor" class="w-4 h-4 text-[#858585]">
                <path d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/>
              </svg>
            <% end %>
            <span class="truncate" title={file.path}><%= file.name %></span>
          </div>
        </div>
      </div>


    </div>
    """
  end
end
