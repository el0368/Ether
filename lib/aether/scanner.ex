defmodule Aether.Scanner do
  @moduledoc """
  High-performance directory scanner.
  
  Currently implemented in Pure Elixir efficiently using recursive Task.async_stream
  due to Zigler 0.15.x compilation issues on Windows.
  
  Future-proof: This module can be swapped for a Zig NIF later without changing the API.
  """
  
  @doc "Scans a directory recursively and returns a list of `{path, type}` tuples."
  def scan(path \\ ".") do
    path = Path.expand(path)
    
    # Delegate strictly to the Zig/C NIF.
    # We do NOT fallback to Elixir to ensure we catch native bugs immediately.
    case Aether.Native.Scanner.scan(path) do
      {:ok, files} -> 
        files
      {:error, reason} -> 
        # Hard warning to ensure visibility
        Logger.error("NIF Scan Failed: #{inspect(reason)}")
        raise "Native Scanner Failure: #{inspect(reason)}"
    end
  end

  require Logger
end
