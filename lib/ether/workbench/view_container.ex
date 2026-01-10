defmodule Ether.Workbench.ViewContainer do
  @moduledoc """
  Defines a panel in the sidebar or other composite parts.
  """
  @type t :: %__MODULE__{
          id: String.t(),
          icon: String.t(),
          label: String.t(),
          module: module(),
          badge: integer() | nil
        }
  defstruct [:id, :icon, :label, :module, :badge]
end
