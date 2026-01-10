defmodule Ether.Explorer do
  @moduledoc """
  Logic for processing and transforming file system data for the UI.
  """

  def sort_files(files) do
    Enum.sort_by(files, fn f -> {!f.is_dir, f.name} end)
  end

  def process_scan_item({path, type}, root) do
    name = Path.basename(path)
    is_dir = type == :directory

    # Calculate depth relative to root
    # e.g. root = "c:/foo", path = "c:/foo/bar/baz.ex"
    # rel = "bar/baz.ex", depth = 2
    rel_path = Path.relative_to(path, root)

    depth =
      if rel_path == "." do
        0
      else
        rel_path |> Path.split() |> length()
      end

    %{
      id: path,
      name: name,
      path: path,
      is_dir: is_dir,
      depth: depth,
      expanded: false
    }
  end
end
