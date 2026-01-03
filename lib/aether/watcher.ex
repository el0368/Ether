defmodule Aether.Watcher do
  @moduledoc """
  File system watcher that emits delta events for incremental tree updates.
  Uses :file_system library to monitor file changes.
  """
  use GenServer
  require Logger

  @name __MODULE__

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  def watch(path) do
    GenServer.cast(@name, {:watch, path})
  end

  def stop_watching do
    GenServer.cast(@name, :stop)
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    Logger.info("Watcher: Initializing...")
    {:ok, %{watcher_pid: nil, watched_path: nil}}
  end

  @impl true
  def handle_cast({:watch, path}, state) do
    # Stop existing watcher if any
    if state.watcher_pid do
      GenServer.stop(state.watcher_pid, :normal)
    end

    # Start new watcher
    case FileSystem.start_link(dirs: [path]) do
      {:ok, pid} ->
        FileSystem.subscribe(pid)
        Logger.info("Watcher: Monitoring #{path}")
        {:noreply, %{state | watcher_pid: pid, watched_path: path}}

      {:error, reason} ->
        Logger.error("Watcher: Failed to start - #{inspect(reason)}")
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast(:stop, state) do
    if state.watcher_pid do
      GenServer.stop(state.watcher_pid, :normal)
    end

    {:noreply, %{state | watcher_pid: nil, watched_path: nil}}
  end

  @impl true
  def handle_info({:file_event, watcher_pid, {path, events}}, state)
      when watcher_pid == state.watcher_pid do
    # Determine event type
    event_type = categorize_events(events)

    # Broadcast to channel
    Phoenix.PubSub.broadcast(
      Aether.PubSub,
      "filetree:deltas",
      {:file_delta, %{path: path, type: event_type}}
    )

    Logger.debug("Watcher: #{event_type} -> #{path}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    Logger.info("Watcher: Stopped")
    {:noreply, %{state | watcher_pid: nil}}
  end

  @impl true
  def handle_info(_, state), do: {:noreply, state}

  # Helpers

  defp categorize_events(events) do
    cond do
      :created in events -> :add
      :removed in events or :deleted in events -> :remove
      :modified in events -> :modify
      :renamed in events -> :rename
      true -> :unknown
    end
  end
end
