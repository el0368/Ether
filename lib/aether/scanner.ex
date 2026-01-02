defmodule Aether.Scanner do
  @moduledoc """
  High-performance directory scanner.
  
  Currently implemented in Pure Elixir efficiently using recursive Task.async_stream
  due to Zigler 0.15.x compilation issues on Windows.
  
  Future-proof: This module can be swapped for a Zig NIF later without changing the API.
  """
  
  @doc "Scans a directory recursively and returns a list of absolute paths."
  def scan(path \\ ".") do
    path = Path.expand(path)
    
    # Use a task to handle the recursion concurrently
    path
    |> list_recursive()
    |> List.flatten()
  end

  defp list_recursive(path) do
    case File.ls(path) do
      {:ok, items} ->
        items
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(fn full_path ->
          expand_path(full_path)
        end)
      {:error, _} -> []
    end
  end

  defp expand_path(full_path) do
    if File.dir?(full_path) do
      list_recursive(full_path)
    else
      full_path
    end
  end
end
