defmodule EtherWeb.Components.Workbench.Sidebar do
  @moduledoc """
  The Sidebar component - contains the file explorer, search, and git panels.
  Follows VS Code's sidebarPart.ts architecture pattern.
  """
  use Phoenix.Component
  import EtherWeb.CoreComponents

  attr :active_sidebar, :string, required: true
  attr :active_file, :map, default: nil
  attr :file_count, :integer, required: true
  attr :is_loading, :boolean, required: true
  attr :files, :list, required: true

  def sidebar(assigns) do
    ~H"""
    <div class="w-[var(--vscode-sidebar-width)] min-w-[var(--vscode-sidebar-width)] bg-[var(--vscode-sidebar-background)] flex flex-col border-r border-[#2b2b2b]">
      <div class="h-[35px] flex items-center justify-between px-4 text-[11px] font-bold uppercase tracking-wider text-[#bbbbbb] opacity-80">
        <span><%= panel_title(@active_sidebar) %></span>
        <.icon name="hero-ellipsis-horizontal" class="w-4 h-4 cursor-pointer" />
      </div>
      <div class="flex-1 overflow-y-auto overflow-x-hidden no-scrollbar text-[var(--vscode-sidebar-foreground)] py-1">
        <%= case @active_sidebar do %>
          <% "files" -> %>
            <.file_explorer files={@files} active_file={@active_file} file_count={@file_count} is_loading={@is_loading} />
          <% "search" -> %>
            <.search_panel />
          <% "git" -> %>
            <.git_panel />
          <% _ -> %>
            <.file_explorer files={@files} active_file={@active_file} file_count={@file_count} is_loading={@is_loading} />
        <% end %>
      </div>
    </div>
    """
  end

  defp panel_title("files"), do: "Explorer"
  defp panel_title("search"), do: "Search"
  defp panel_title("git"), do: "Source Control"
  defp panel_title(_), do: "Explorer"

  attr :files, :list, required: true
  attr :active_file, :map, default: nil
  attr :file_count, :integer, required: true
  attr :is_loading, :boolean, required: true

  defp file_explorer(assigns) do
    ~H"""
    <div id="file-tree" phx-update="stream" class="w-full">
      <div
        :for={{id, file} <- @files}
        id={id}
        class={"group flex items-center pr-2 cursor-pointer hover:bg-[#2a2d2e] select-none text-[13px] leading-[22px] #{if @active_file && @active_file.path == file.path, do: "bg-[#37373d]"}"}
        style={"padding-left: #{file.depth * 12 + 8}px"}
        phx-click="select_file"
        phx-value-path={file.path}
      >
        <div class="flex items-center gap-1.5 w-full overflow-hidden">
          <%= if file.is_dir do %>
            <.icon name={if file.expanded, do: "hero-chevron-down-micro", else: "hero-chevron-right-micro"} class="w-3.5 h-3.5 text-[#858585]" />
            <.icon name="hero-folder-solid" class="w-4 h-4 text-[#858585]" />
          <% else %>
            <div class="w-3.5"></div>
            <.icon name="hero-document-text" class="w-4 h-4 text-[#858585]" />
          <% end %>
          <span class="truncate"><%= file.name %></span>
        </div>
      </div>
    </div>

    <%= if @file_count == 0 && !@is_loading do %>
      <div class="flex flex-col items-center justify-center p-8 text-center h-full gap-4">
        <p class="text-[12px] opacity-60">You have not yet opened a folder.</p>
        <button
          phx-click="open_folder"
          class="px-4 py-2 bg-[#007acc] hover:bg-[#0062a3] text-white text-[12px] rounded transition-colors font-medium shadow-lg"
        >
          Open Folder
        </button>
      </div>
    <% end %>
    """
  end

  defp search_panel(assigns) do
    ~H"""
    <div class="p-4 text-center text-[12px] opacity-60">
      <p>Search functionality coming soon...</p>
    </div>
    """
  end

  defp git_panel(assigns) do
    ~H"""
    <div class="p-4 text-center text-[12px] opacity-60">
      <p>Source control coming soon...</p>
    </div>
    """
  end
end
