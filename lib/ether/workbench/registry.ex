defmodule Ether.Workbench.Registry do
  @moduledoc """
  A central registry of all available views in the IDE.
  """
  alias Ether.Workbench.ViewContainer

  def all do
    [
      %ViewContainer{
        id: "files",
        icon: "lucide-copy",
        label: "Explorer",
        module: EtherWeb.Workbench.ExplorerView
      },
      %ViewContainer{
        id: "search",
        icon: "lucide-search",
        label: "Search",
        module: nil # Placeholder
      },
      %ViewContainer{
        id: "git",
        icon: "lucide-git-branch",
        label: "Source Control",
        module: nil # Placeholder
      },
      %ViewContainer{
        id: "debug",
        icon: "lucide-play-circle",
        label: "Run and Debug",
        module: nil
      },
      %ViewContainer{
        id: "extensions",
        icon: "lucide-layout-grid",
        label: "Extensions",
        module: nil
      }
    ]
  end

  def get_view(id) do
    Enum.find(all(), &(&1.id == id))
  end
end
