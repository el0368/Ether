defmodule Aether.Native.Bridge do
  @moduledoc """
  The Resilient Bridge.
  Attempts to use the Zig Native Scanner (The Reflex).
  If it fails (crash, error, or missing), falls back to the Elixir Scanner (The Brain).
  """
  require Logger

  def scan(path) do
    Logger.debug("Reflex: Attempting Native Scan...")
    
    # Try calling the Native Scanner
    try do
      # We check if the native module is loaded and available
      if Code.ensure_loaded?(Aether.Native.Scanner) do
        case Aether.Native.Scanner.scan(path) do
          {:ok, result} -> 
            Logger.info("Reflex: Native Scan Successful.")
            {:ok, result}
          {:error, reason} ->
            Logger.warning("Reflex: Native Scan Error: #{inspect(reason)}. Engage Fallback.")
            fallback_scan(path)
        end
      else
        Logger.info("Reflex: Native Module not loaded. Engage Fallback.")
        fallback_scan(path)
      end
    rescue
      e ->
        Logger.error("Reflex: Native Crash/Exception: #{inspect(e)}. Engage Fallback.")
        fallback_scan(path)
    catch
      :exit, _reason ->
        Logger.error("Reflex: NIF Exit Detected. Engage Fallback.")
        fallback_scan(path)
    end
  end

  defp fallback_scan(path) do
    Logger.info("Brain: Engaging Elixir Fallback Scanner.")
    Aether.Scanner.scan(path)
  end
end
