defmodule Ether.Native.Scanner do
  @moduledoc """
  NIF Loader for the Native Scanner.
  Loads the manually compiled `scanner_nif.dll` from `priv/native`.
  
  Supports:
  - File scanning via `scan/1` and `scan_raw/1`
  - Resource contexts via `create_context/0` and `close_context/1` (ADR-017)
  """
  require Logger
  @on_load :load_nif

  def load_nif do
    path = Application.app_dir(:ether, "priv/native/scanner_nif")
    |> String.to_charlist()

    case :erlang.load_nif(path, 0) do
      :ok -> :ok
      {:error, {:load_failed, reason}} ->
        Logger.error("Failed to load Native Scanner NIF: #{path}")
        Logger.error("Reason: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # =============================================================================
  # File Scanning (Level 5)
  # =============================================================================
  
  def scan(path) do
    case scan_nif(path, self()) do
      :ok -> :ok
      error -> error
    end
  end

  def scan_raw(path) do
    scan_nif(path, self())
  end


  # =============================================================================
  # Resource Context Management (ADR-017 / Level 6)
  # =============================================================================
  
  @doc """
  Creates a new native resource context.
  Returns `{:ok, reference}` on success.
  The reference is managed by the BEAM GC - when it's garbage collected,
  the native destructor is called automatically.
  """
  def create_context do
    create_context_nif()
  end

  @doc """
  Closes a native resource context.
  """
  def close_context(ref), do: close_context_nif(ref)

  @doc """
  Searches for a query string in a file.
  Returns `:match` or `:no_match` (Phase 6 Sync Prototype).
  """
  def search(context, query, path), do: search_nif(context, query, path)

  # NIF Stubs (Fallbacks if DLL fails to load)
  defp scan_nif(_path, _pid), do: :erlang.nif_error(:nif_not_loaded)
  defp create_context_nif(), do: :erlang.nif_error(:nif_not_loaded)
  defp close_context_nif(_ref), do: :erlang.nif_error(:nif_not_loaded)
  defp search_nif(_ctx, _query, _path), do: :erlang.nif_error(:nif_not_loaded)
end
