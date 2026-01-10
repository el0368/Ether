defmodule Ether.Workbench.Storage do
  @moduledoc """
  Simple file-based storage for workbench state.
  """
  alias Ether.Workbench.LayoutState

  @storage_path "priv/storage/layout.json"

  def save(layout) do
    # Async save to prevent blocking the UI thread (LiveView)
    # TODO: Migrate to GenServer for serialized writes if race conditions occur
    Task.start(fn ->
      File.mkdir_p!(Path.dirname(@storage_path))
      content = Jason.encode!(layout)
      File.write!(@storage_path, content)
    end)
  end

  def load do
    if File.exists?(@storage_path) do
      @storage_path
      |> File.read!()
      |> Jason.decode!(keys: :atoms)
      |> then(fn data -> struct(LayoutState, data) end)
    else
      LayoutState.new()
    end
  rescue
    _ -> LayoutState.new()
  end
end
