defmodule Aether.Agents.FileServerAgent do
  @moduledoc """
  GenServer for safe file system operations.
  Provides read, write, and list functionality.
  """
  use GenServer
  require Logger

  @name __MODULE__

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def read_file(path) do
    GenServer.call(@name, {:read, path})
  end

  def write_file(path, content) do
    GenServer.call(@name, {:write, path, content})
  end

  def list_files(path) do
    GenServer.call(@name, {:list, path})
  end

  def search(query) do
    GenServer.call(@name, {:search, query})
  end

  def get_recent_files do
    GenServer.call(@name, :get_recent)
  end



  # Server Callbacks

  @impl true
  def init(_state) do
    Logger.info("FileServerAgent started")
    {:ok, %{recent_files: []}}
  end

  @impl true
  def handle_call({:read, path}, _from, state) do
    result = 
      case File.read(path) do
        {:ok, content} -> {:ok, content}
        {:error, reason} -> 
          Logger.error("Failed to read #{path}: #{inspect(reason)}")
          {:error, reason}
      end
    
    # Track this file as recently opened
    new_recent = 
      [path | Enum.reject(state.recent_files, &(&1 == path))]
      |> Enum.take(20)
    
    {:reply, result, %{state | recent_files: new_recent}}
  end

  @impl true
  def handle_call({:write, path, content}, _from, state) do
    result =
      case File.write(path, content) do
        :ok -> :ok
        {:error, reason} ->
          Logger.error("Failed to write #{path}: #{inspect(reason)}")
          {:error, reason}
      end
    {:reply, result, state}
  end



  @impl true
  def handle_call({:list, path}, _from, state) do
    result =
      case File.ls(path) do
        {:ok, entries} ->
          files = 
            entries
            |> Enum.sort()
            |> Enum.map(fn name ->
              full_path = Path.join(path, name)
              %{
                name: name,
                path: full_path,
                is_dir: File.dir?(full_path)
              }
            end)
            |> Enum.sort_by(fn f -> {!f.is_dir, f.name} end)
          {:ok, files}
        {:error, reason} ->
          Logger.error("Failed to list #{path}: #{inspect(reason)}")
          {:error, reason}
      end
    {:reply, result, state}
  end

  @impl true
  def handle_call({:search, query}, _from, state) do
    results = perform_search(".", query)
    {:reply, {:ok, results}, state}
  end

  @impl true
  def handle_call(:get_recent, _from, state) do
    recent = Enum.map(state.recent_files, fn path ->
      %{name: Path.basename(path), path: path}
    end)
    {:reply, {:ok, recent}, state}
  end

  defp perform_search(dir, query) do
    case File.ls(dir) do
      {:ok, entries} ->
        Enum.flat_map(entries, fn entry ->
          path = Path.join(dir, entry)
          cond do
            String.starts_with?(entry, ".") -> []
            entry == "_build" or entry == "deps" or entry == "assets/node_modules" -> []
            File.dir?(path) -> perform_search(path, query)
            is_text_file(path) -> search_in_file(path, query)
            true -> []
          end
        end)
      _ -> []
    end
  end

  defp is_text_file(path) do
    ext = Path.extname(path)
    ext in [".ex", ".exs", ".js", ".svelte", ".css", ".md", ".json", ".html", ".heex"]
  end

  defp search_in_file(path, query) do
    case File.read(path) do
      {:ok, content} ->
        content
        |> String.split("\n")
        |> Enum.with_index(1)
        |> Enum.filter(fn {line, _} -> String.contains?(line, query) end)
        |> Enum.map(fn {line, index} ->
          %{path: path, line: index, content: String.trim(line)}
        end)
      _ -> []
    end
  end
end
