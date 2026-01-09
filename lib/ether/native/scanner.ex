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
      {:error, reason} ->
        Logger.error("Failed to load Native Scanner NIF: #{path}")
        Logger.error("Reason: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # =============================================================================
  # File Scanning (Level 5 Stability)
  # =============================================================================
  
  @doc """
  Initiates a file scan.
  Isolates the NIF call in a supervised Task to prevent blocking the caller.
  """
  def scan(path, ignores \\ [], depth_limit \\ 64) do
    caller = self()
    Task.start(fn ->
      {:ok, resource} = create_context_nif(ignores)
      case do_scan_loop(resource, path, caller, depth_limit) do
        {:ok, count} -> 
          close_context_nif(resource)
          {:ok, count}
        :ok ->
          close_context_nif(resource)
          :ok
        {:error, reason} -> 
          Logger.error("Scanner NIF failed: #{inspect(reason)}")
          send(caller, {:scanner_error, reason})
          close_context_nif(resource)
        unknown -> 
          Logger.error("Scanner NIF returned unknown result: #{inspect(unknown)}")
          send(caller, {:scanner_error, :unknown_native_failure})
          close_context_nif(resource)
      end
    end)
    :ok
  end

  defp do_scan_loop(resource, path, pid, depth_limit) do
    case scan_yield_nif(resource, path, pid, depth_limit) do
      count when is_integer(count) -> {:ok, count}
      :ok -> :ok
      {:cont, ^resource} ->
        # Yielding happened! Elixir loop resumes execution
        # The scheduler will naturally preempt this process if needed.
        do_scan_loop(resource, path, pid, depth_limit)
      {:error, _} = err -> err
      unknown -> {:error, {:unknown_native_failure, unknown}}
    end
  end

  @doc """
  Creates a new native resource context.
  """
  def create_context(ignores \\ []) do
    create_context_nif(ignores)
  end

  @doc """
  Closes a native resource context.
  """
  def close_context(ref), do: close_context_nif(ref)

  @doc """
  Searches for a query string in a file or directory recursively.
  Returns `{:ok, [match_path_1, match_path_2, ...]}` on success.
  (Level 6 Parallel Performance)
  """
  def search(context, query, path), do: search_nif(context, query, path)

  @doc """
  Legacy raw scan (mostly for testing).
  Now uses the yieldable loop for consistency.
  """
  def scan_raw(path) do
    {:ok, resource} = create_context_nif([])
    result = do_scan_loop(resource, path, self(), 64)
    close_context(resource)
    result
  end

  # NIF Stubs (Fallbacks if DLL fails to load)
  def scan_yield_nif(_ref, _path, _pid, _limit), do: :erlang.nif_error(:nif_not_loaded)
  defp create_context_nif(_ignores), do: :erlang.nif_error(:nif_not_loaded)
  defp close_context_nif(_ref), do: :erlang.nif_error(:nif_not_loaded)
  defp search_nif(_ctx, _query, _path), do: :erlang.nif_error(:nif_not_loaded)
end
