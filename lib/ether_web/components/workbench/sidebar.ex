defmodule EtherWeb.Components.Workbench.Sidebar do
  use Phoenix.Component
  import EtherWeb.Workbench.ViewPaneContainer

  attr :active_sidebar, :string, required: true
  attr :active_file, :map, default: nil
  attr :file_count, :integer, required: true
  attr :is_loading, :boolean, required: true
  attr :files, :list, required: true

  def sidebar(assigns) do
    # Define the pane configuration based on active sidebar
    panes = get_panes(assigns)
    assigns = assign(assigns, :panes, panes)
    
    ~H"""
    <div class="w-[var(--vscode-sidebar-width)] min-w-[var(--vscode-sidebar-width)] bg-[var(--vscode-sidebar-background)] border-r border-[#2b2b2b]">
      <.view_pane_container 
        id="sidebar-container"
        title={panel_title(@active_sidebar)}
        panes={@panes}
      />
    </div>
    """
  end

  defp panel_title("files"), do: "Explorer"
  defp panel_title("search"), do: "Search"
  defp panel_title("git"), do: "Source Control"
  defp panel_title(_), do: "Explorer"

  defp get_panes(assigns) do
    case assigns.active_sidebar do
      "files" ->
        [
          %{
            id: "open_editors",
            title: "Open Editors",
            component: EtherWeb.Workbench.FilterWidget, 
            expanded: true,
            assigns: %{placeholder: "Search editors..."}
          },
          %{
            id: "folders",
            title: "Folders", # Should technically be folder name
            component: EtherWeb.Workbench.ExplorerView,
            expanded: true,
            assigns: %{
              files: assigns.files,
              active_file: assigns.active_file,
              file_count: assigns.file_count,
              is_loading: assigns.is_loading
            }
          },
          %{
            id: "outline",
            title: "Outline",
            component: nil,
            expanded: false,
            assigns: %{}
          },
          %{
            id: "timeline",
            title: "Timeline",
            component: nil,
            expanded: false,
            assigns: %{}
          }
        ]
      
      _ -> []
    end
  end
end
