defmodule Ether.Scanner do
  @moduledoc """
  High-performance directory scanner.
  
  Delegates to the Safe Native (Zig) Scanner (Level 4).
  """
  require Logger
  
  @doc "Scans a directory recursively and returns a list of `{path, type}` tuples."

  def scan(path \\ ".") do
    path = Path.expand(path)
    
    # Delegate strictly to the Zig/C NIF.
    # POLICY: No Fallback. If NIF fails/crashes, we crash.
    :ok = Ether.Native.Scanner.scan(path)
    collect_and_decode(path, [])
  end

  defp collect_and_decode(root, acc_binaries) do
    receive do
      {:scanner_chunk, bin} -> 
        collect_and_decode(root, [bin | acc_binaries])
      {:scanner_done, :ok} ->
        # Join all chunks reversed (since we prepended)
        full_binary = acc_binaries |> Enum.reverse() |> IO.iodata_to_binary()
        decode_slab(full_binary, root, [])
      {:scanner_error, reason} ->
        Logger.error("NIF Scan Failed: #{inspect(reason)}")
        raise "Native Scanner Failure: #{inspect(reason)}"
    after
      5000 -> raise "Scanner Timeout: NIF did not reply."
    end
  end

  defp decode_slab(<<>>, _root, acc), do: Enum.reverse(acc)
  defp decode_slab(<<type::8, len::16-little, path_bin::binary-size(len), rest::binary>>, root, acc) do
    rel_path = String.to_charlist(path_bin) |> List.to_string() # Ensure string
    abs_path = Path.join(root, rel_path)
    type_atom = if type == 2, do: :directory, else: :file
    decode_slab(rest, root, [{abs_path, type_atom} | acc])
  end
  defp decode_slab(rest, _root, acc) do
    Logger.warning("Scanner: Junk remaining in slab: #{byte_size(rest)} bytes")
    Enum.reverse(acc)
  end

  def scan_raw(path \\ ".") do
    path = Path.expand(path)
    # Strictly call NIF. No rescue.
    Ether.Native.Scanner.scan_raw(path)
  end
end
