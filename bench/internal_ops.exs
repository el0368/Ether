defmodule InternalOpsBench do
  @moduledoc """
  Internal operations benchmark for Ether Backend.
  Measures JSON serialization, GenServer roundtrips, and Path logic overhead.
  """

  # Try to require Benchee, but don't fail if it's missing (we might need to add it to mix.exs)
  # Actually, I should check if benchee is in mix.exs.
  
  def run do
    IO.puts("\n⚙️  Internal Operations Benchmark")
    IO.puts("=" |> String.duplicate(50))

    json = bench_json_overhead()
    gs = bench_genserver_latency()
    path = bench_path_logic()

    metrics = %{
      metric_type: "backend",
      json_encode_ms: json.encode,
      json_decode_ms: json.decode,
      genserver_latency_us: gs.avg,
      path_logic_ms: path.time
    }

    if Code.ensure_loaded?(Ether.Benchmark) do
      Ether.Benchmark.record_metrics(metrics)
      IO.puts("\n✅ Recorded Backend metrics to Studio")
    end

    metrics
  end

  defp bench_json_overhead do
    IO.puts("\n📦 JSON Overhead (Jason)")
    
    # Large mock file tree
    data = for i <- 1..1000 do
      %{
        "name" => "file_#{i}.ex",
        "path" => "/root/subdir/another_subdir/file_#{i}.ex",
        "size" => i * 1024,
        "type" => "file",
        "metadata" => %{
          "hash" => "abc#{i}",
          "last_modified" => System.system_time(:second)
        }
      }
    end

    {time_enc, _} = :timer.tc(fn -> Jason.encode!(data) end)
    json_string = Jason.encode!(data)
    {time_dec, _} = :timer.tc(fn -> Jason.decode!(json_string) end)

    IO.puts("  Encode (1000 nodes): #{Float.round(time_enc / 1000, 2)} ms")
    IO.puts("  Decode (1000 nodes): #{Float.round(time_dec / 1000, 2)} ms")

    %{encode: time_enc / 1000, decode: time_dec / 1000}
  end

  defp bench_genserver_latency do
    IO.puts("\n🔄 GenServer Latency (Agent Roundtrip)")
    
    # We'll use a simple Agent as a proxy for our GenServers
    {:ok, pid} = Agent.start_link(fn -> %{} end)
    
    measurements = for _ <- 1..1000 do
      t0 = System.monotonic_time(:microsecond)
      Agent.get(pid, fn state -> state end)
      t1 = System.monotonic_time(:microsecond)
      t1 - t0
    end

    Agent.stop(pid)

    avg = Enum.sum(measurements) / length(measurements)
    IO.puts("  Average Roundtrip: #{Float.round(avg, 2)} µs")
    %{avg: avg}
  end

  defp bench_path_logic do
    IO.puts("\n📂 Path Logic Efficiency")
    
    paths = for i <- 1..1000, do: "c:/GitHub/Ether/lib/aether/agents/file_#{i}.ex"
    
    {time, _} = :timer.tc(fn ->
      Enum.each(paths, fn p ->
        Path.dirname(p)
        Path.basename(p)
        Path.extname(p)
      end)
    end)

    IO.puts("  Path processing (1000 ops): #{Float.round(time / 1000, 2)} ms")
    %{time: time / 1000}
  end
end

if System.argv() == [] do
  InternalOpsBench.run()
end
