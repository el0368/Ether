defmodule Ether.Agents.ScannerAgent do
  @moduledoc """
  GenServer that orchestrates the Zig-powered scanner.
  Pushes file updates to a target process (e.g., LiveView).
  """
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def scan(pid, path, ignores \\ [".git", "node_modules", "_build", "deps"]) do
    GenServer.cast(pid, {:scan, path, ignores})
  end

  # Server Callbacks

  def init(opts) do
    target = Keyword.get(opts, :target) || self()
    {:ok, %{target: target, root_path: nil, file_count: 0}}
  end

  def handle_cast({:scan, path, ignores}, state) do
    path = Path.expand(path)
    Logger.info("Starting Zig scan on #{path}")
    
    # Delegate to Native Scanner
    # The Native Scanner already runs in its own Task and sends messages
    # We will forward messages to the target LiveView
    Ether.Native.Scanner.scan(path, ignores, 64)
    
    {:noreply, %{state | root_path: path}}
  end

  # Forward messages from Native Scanner to the target
  def handle_info({:scanner_chunk, _} = msg, state) do
    send(state.target, msg)
    {:noreply, state}
  end

  def handle_info({:scanner_sync, _} = msg, state) do
    send(state.target, msg)
    {:noreply, state}
  end

  def handle_info({:scanner_done, _} = msg, state) do
    send(state.target, msg)
    {:noreply, state}
  end

  def handle_info({:scanner_error, _} = msg, state) do
    send(state.target, msg)
    {:noreply, state}
  end
end
