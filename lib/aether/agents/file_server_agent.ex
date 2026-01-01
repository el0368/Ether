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

  # Server Callbacks

  @impl true
  def init(state) do
    Logger.info("FileServerAgent started")
    {:ok, state}
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
    {:reply, result, state}
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
end
