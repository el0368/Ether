defmodule Aether.Scanner do
  @moduledoc """
  High-performance directory scanner.
  
  Delegates to the Safe Native (Zig) Scanner (Level 4).
  """
  require Logger
  
  @doc "Scans a directory recursively and returns a list of `{path, type}` tuples."
  def scan(path \\ ".") do
    path = Path.expand(path)
    
    # Delegate strictly to the Zig/C NIF.
    case Aether.Native.Scanner.scan(path) do
      {:ok, files} -> 
        files
      {:error, reason} -> 
        # Hard warning to ensure visibility
        Logger.error("NIF Scan Failed: #{inspect(reason)}")
        raise "Native Scanner Failure: #{inspect(reason)}"
    end
  end
end
