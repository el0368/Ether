defmodule Ether.Workbench.LayoutState do
  @moduledoc """
  Manages the visual state of the workbench layout.
  """
  @derive Jason.Encoder
  alias Ether.Workbench.Registry

  @type t :: %__MODULE__{
          active_id: String.t(),
          visible: boolean(),
          pinned_ids: [String.t()],
          sidebar_width: integer()
        }
  defstruct [
    active_id: "files",
    visible: true,
    pinned_ids: ["files", "search", "git", "debug", "extensions"],
    sidebar_width: 260
  ]

  def new do
    %__MODULE__{}
  end

  def reset do
    %__MODULE__{}
  end

  @doc """
  Smart Toggle Logic:
  - Clicking active view + visible -> Hide.
  - Clicking active view + hidden -> Show.
  - Clicking different view -> Switch and ensure visible.
  """
  def toggle_view(state, view_id) do
    cond do
      state.active_id == view_id and state.visible ->
        %{state | visible: false}

      state.active_id == view_id and not state.visible ->
        %{state | visible: true}

      true ->
        %{state | active_id: view_id, visible: true}
    end
  end

  def pin_view(state, view_id) do
    if view_id in state.pinned_ids do
      state
    else
      %{state | pinned_ids: state.pinned_ids ++ [view_id]}
    end
  end

  def unpin_view(state, view_id) do
    # Prevent unpinning if it's the last one? VS Code allows unpinning all.
    %{state | pinned_ids: List.delete(state.pinned_ids, view_id)}
  end

  def reorder_views(state, id, to_index) do
    ids = state.pinned_ids
    from_index = Enum.find_index(ids, &(&1 == id))

    if from_index do
      new_ids = 
        ids 
        |> List.delete_at(from_index)
        |> List.insert_at(to_index, id)

      %{state | pinned_ids: new_ids}
    else
      state
    end
  end

  def set_width(state, width) do
    %{state | sidebar_width: width}
  end

  def pinned_containers(state) do
    state.pinned_ids
    |> Enum.map(&Registry.get_view/1)
    |> Enum.reject(&is_nil/1)
  end

  def active_container(state) do
    Registry.get_view(state.active_id)
  end
end
