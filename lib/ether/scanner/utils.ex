defmodule Ether.Scanner.Utils do
  @moduledoc """
  High-performance utilities for decoding native scanner output.
  """

  @doc """
  Decodes a binary slab into a list of file items.
  Optimized for direct binary pattern matching without conversion overhead.
  """
  @spec decode_slab(binary(), String.t()) :: [{String.t(), atom(), integer()}]
  def decode_slab(binary, _root) when is_binary(binary) do
    decode_entries(binary, [])
  end

  defp decode_entries(<<>>, acc), do: Enum.reverse(acc)
  defp decode_entries(<<type::8, depth::8, len::16-little, path_bin::binary-size(len), rest::binary>>, acc) do
    # Normalize slashes for consistency across OS/Tools
    path = String.replace(path_bin, "\\", "/")
    type_atom = if type == 2, do: :directory, else: :file
    decode_entries(rest, [{path, type_atom, depth} | acc])
  end
  defp decode_entries(_junk, acc), do: Enum.reverse(acc)

  @doc """
  Transforms a {path, type, depth} or {path, type} tuple into a UI-ready map.
  Uses pre-calculated native depth if available, otherwise falls back to calculation.
  """
  @spec to_ui_item({String.t(), atom(), integer()} | {String.t(), atom()}, String.t()) :: map()
  def to_ui_item({path, type, depth}, _root) do
    build_ui_map(path, type, depth)
  end

  def to_ui_item({path, type}, root) do
    depth = calculate_depth(path, root)
    build_ui_map(path, type, depth)
  end

  defp build_ui_map(path, type, depth) do
    name = Path.basename(path)
    is_dir = type == :directory

    %{
      id: path,
      name: name,
      path: path,
      is_dir: is_dir,
      depth: depth,
      expanded: false
    }
  end

  # O(1) depth calculation by counting separators in the relative portion
  defp calculate_depth(path, root) do
    root = String.replace(root, "\\", "/")
    path = String.replace(path, "\\", "/")
    
    root_len = byte_size(root)
    path_len = byte_size(path)

    if path_len > root_len do
      # Get relative portion (skip root + separator)
      rel_start = root_len + 1
      if path_len > rel_start do
        rel_part = binary_part(path, rel_start, path_len - rel_start)
        count_separators(rel_part, 0) + 1
      else
        0
      end
    else
      0
    end
  end

  defp count_separators(<<>>, count), do: count
  defp count_separators(<<c, rest::binary>>, count) when c in [?/, ?\\] do
    count_separators(rest, count + 1)
  end
  defp count_separators(<<_, rest::binary>>, count) do
    count_separators(rest, count)
  end
end
