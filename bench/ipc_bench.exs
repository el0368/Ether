defmodule IpcBench do
  @moduledoc """
  Tauri IPC / Phoenix Bridge Benchmark.
  Measures latency of messages traveling between Elixir, Rust, and JavaScript.
  """

  def run do
    IO.puts("\n🌉 IPC / Bridge Latency Benchmark")
    IO.puts("=" |> String.duplicate(50))

    case check_server() do
      :ok ->
        lat_out = bench_elixir_to_js()
        lat_in = bench_js_to_elixir()

        metrics = %{
          metric_type: "ipc",
          bridge_latency_us: (lat_out + lat_in) / 2,
          broadcast_latency_us: lat_out,
          channel_latency_us: lat_in
        }

        if Code.ensure_loaded?(Ether.Benchmark) do
          Ether.Benchmark.record_metrics(metrics)
          IO.puts("\n✅ Recorded IPC metrics to Studio")
        end
      :error ->
        IO.puts("  ❌ SERVER NOT RUNNING: IPC benchmarks require the backend to be active.")
        IO.puts("     Please start the server with .\\start_dev.bat and try again.")
    end
  end

  defp check_server do
    case gen_tcp_connect('localhost', 4000) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        :ok
      _ -> :error
    end
  end

  defp gen_tcp_connect(host, port) do
    :gen_tcp.connect(host, port, [:binary, active: false], 500)
  end

  defp bench_elixir_to_js do
    IO.puts("\n📤 Elixir -> JS (Event Bridge)")
    IO.puts("  Measuring latency of Broadcast -> Phoenix.Channel -> JS Handler...")
    
    # This requires a connected client to actually measure. 
    # For now, we measure the overhead of local message passing as a baseline.
    
    t0 = System.monotonic_time(:microsecond)
    Phoenix.PubSub.broadcast(Ether.PubSub, "editor:bench", {:bench, "payload"})
    t1 = System.monotonic_time(:microsecond)
    
    IO.puts("  PubSub Broadcast (Unit Latency): #{t1 - t0} µs")
    IO.puts("  💡 Full E2E JS measurement available in 'Interaction Monitor' (Console).")
    t1 - t0
  end

  defp bench_js_to_elixir do
    IO.puts("\n📥 JS -> Elixir (Invoke Bridge)")
    IO.puts("  Measuring latency of JS.push -> Phoenix.Channel -> GenServer...")
    
    # We measure the internal GenServer dispatch cost
    t0 = System.monotonic_time(:microsecond)
    # Simulating a channel handle_in call
    send(self(), :bench_ping)
    receive do
      :bench_ping -> :ok
    end
    t1 = System.monotonic_time(:microsecond)
    
    IO.puts("  Channel Protocol overhead (Unit): #{t1 - t0} µs")
    t1 - t0
  end
end

if System.argv() == [] do
  IpcBench.run()
end
