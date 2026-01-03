defmodule Aether.Native.Scanner do
  @moduledoc """
  NIF Loader for the Native Scanner.
  Loads the manually compiled `scanner_nif.dll` from `priv/native`.
  """
  require Logger
  @on_load :load_nif

  def load_nif do
    # Locate the priv directory for the :aether application
    path = Application.app_dir(:aether, "priv/native/scanner_nif")
    |> String.to_charlist()

    case :erlang.load_nif(path, 0) do
      :ok -> :ok
      {:error, {:load_failed, reason}} ->
        Logger.error("Failed to load Native Scanner NIF: #{path}")
        Logger.error("Reason: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def scan(_path), do: :erlang.nif_error(:nif_not_loaded)
end
