defmodule Ether.Scanner.Utils do
  @moduledoc """
  High-performance utilities for decoding native scanner output.
  """

  @doc """
  Decodes a binary slab into a list of file items.
  Optimized for direct binary pattern matching without conversion overhead.
  """
  @spec decode_slab(binary(), String.t()) :: [{String.t(), atom()}]
  def decode_slab(binary, root) when is_binary(binary) do
    decode_entries(binary, root, [])
  end

  defp decode_entries(<<>>, _root, acc), do: acc
  defp decode_entries(<<type::8, len::16-little, path_bin::binary-size(len), rest::binary>>, root, acc) do
    abs_path = Path.join(root, path_bin)
    type_atom = if type == 2, do: :directory, else: :file
    decode_entries(rest, root, [{abs_path, type_atom} | acc])
  end
  defp decode_entries(_junk, _root, acc), do: acc

  @doc """
  Transforms a {path, type} tuple into a UI-ready map.
  Calculates depth by counting path separators for O(1) performance.
  """
  @spec to_ui_item({String.t(), atom()}, String.t()) :: map()
  def to_ui_item({path, type}, root) do
    name = Path.basename(path)
    is_dir = type == :directory
    depth = calculate_depth(path, root)

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
    # Get the relative path length after the root
    root_len = byte_size(root)
    path_len = byte_size(path)

    if path_len > root_len do
      # Get relative portion (skip root + separator)
      rel_start = root_len + 1
      rel_part = binary_part(path, rel_start, path_len - rel_start)
      count_separators(rel_part, 0) + 1
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
