defmodule Aether.Native.Scanner do
  @moduledoc """
  The Native Reflex for Aether. 
  Bridges the Elixir Brain to the high-speed Zig Directory Walker.
  
  Uses Manual Native Integration (build_nif.bat) to load the NIF.
  """
  
  # Trigger NIF loading when module is loaded
  @on_load :load_nif

  def load_nif do
    # Path to priv/native/scanner_nif (without .dll extension)
    path = :code.priv_dir(:aether)
    |> Path.join("native/scanner_nif")
    |> String.to_charlist()
    
    # Load the NIF. If it fails, log it but don't crash code loading immediately?
    # standard pattern:
    case :erlang.load_nif(path, 0) do
      :ok -> :ok
      {:error, reason} -> 
        require Logger
        Logger.warning("Native Scanner failed to load: #{inspect(reason)}")
        # Return :ok so module loads, but falls back to nif_error
        :ok
    end
  end

  # Fallback function: If NIF is loaded, this is replaced.
  # If not, this error triggers the Bridge (if configured to catch) or crashes.
  def scan(_path), do: :erlang.nif_error(:nif_not_loaded)
end
