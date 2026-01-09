defmodule Ether.Scanner do
  @moduledoc """
  High-performance directory scanner.
  
  Delegates to the Safe Native (Zig) Scanner (Level 4).
  """
  require Logger
  
  @doc "Scans a directory recursively and returns a list of UI-ready item maps."
  def scan(path \\ ".", ignores \\ [".git", "node_modules", "_build", "deps", ".elixir_ls"], depth_limit \\ 64) do
    path = Path.expand(path)
    
    # Delegate strictly to the Zig/C NIF.
    # POLICY: No Fallback. If NIF fails/crashes, we crash.
    :ok = Ether.Native.Scanner.scan(path, ignores, depth_limit)
    collect_and_decode(path, [])
  end

  @doc "Initiates an asynchronous scan. Results are streamed to the caller as messages."
  def scan_async(path \\ ".", ignores \\ [".git", "node_modules", "_build", "deps", ".elixir_ls"], depth_limit \\ 64) do
    path = Path.expand(path)
    Ether.Native.Scanner.scan(path, ignores, depth_limit)
  end

  defp collect_and_decode(root, acc_items) do
    receive do
      {:scanner_chunk, bin} -> 
        items = 
          Ether.Scanner.Utils.decode_slab(bin, root)
          |> Enum.map(&Ether.Scanner.Utils.to_ui_item(&1, root))
        collect_and_decode(root, items ++ acc_items)
      {:scanner_done, :ok} ->
        # reverse the list since we might have prepended chunks
        Enum.reverse(acc_items)
      {:scanner_error, reason} ->
        Logger.error("NIF Scan Failed: #{inspect(reason)}")
        raise "Native Scanner Failure: #{inspect(reason)}"
    after
      5000 -> raise "Scanner Timeout: NIF did not reply."
    end
  end

  def scan_raw(path \\ ".") do
    path = Path.expand(path)
    # Strictly call NIF. No rescue.
    Ether.Native.Scanner.scan_raw(path)
  end
end
