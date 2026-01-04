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

  def scan(path) do
    # path = String.to_charlist(path) <- INCORRECT. NIF expects Binary.
    case scan_nif(path, self()) do
      :ok -> :ok
      error -> error
    end
  end

  def scan_raw(path) do
    # For raw scanning, we just trigger the stream. 
    # Caller must handle messages.
    scan_nif(path, self())
  end

  def scan_nif(_path, _pid), do: :erlang.nif_error(:nif_not_loaded)


end
