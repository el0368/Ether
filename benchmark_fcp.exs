defmodule Aether.BenchmarkFCP do
  @moduledoc """
  Benchmark: Time to First Contentful Paint (FCP) Proxy
  Measures latency from `scan_raw/1` call to first `{:binary, ...}` message.
  Target: < 5ms
  """

  def run do
    # 1. Setup: Ensure we have a directory to scan
    # We'll usage the current directory (project root) to be realistic
    path = "."

    IO.puts("\n🚀 Aether FCP Benchmark")
    IO.puts("=======================")
    IO.puts("Target: < 5.0 ms")
    IO.puts("Path:   #{Path.expand(path)}")

    # Warmup
    IO.write("Warming up...")
    Aether.Scanner.scan_raw(path)
    flush()
    IO.puts(" Done.")

    # Measure
    measurements =
      for i <- 1..100 do
        t0 = System.monotonic_time(:microsecond)

        :ok = Aether.Scanner.scan_raw(path)

        receive do
          {:binary, _} ->
            t1 = System.monotonic_time(:microsecond)
            # Flush rest
            flush()
            t1 - t0
        after
          1000 ->
            IO.puts("Timeout waiting for chunk!")
            # Penalty
            1_000_000
        end
      end

    # Stats
    avg_us = Enum.sum(measurements) / length(measurements)
    min_us = Enum.min(measurements)
    max_us = Enum.max(measurements)

    avg_ms = avg_us / 1000.0
    min_ms = min_us / 1000.0
    max_ms = max_us / 1000.0

    IO.puts("\n📊 Results (100 runs)")
    IO.puts("---------------------")
    IO.puts("Average Latency: #{Float.round(avg_ms, 3)} ms")
    IO.puts("Best Latency:    #{Float.round(min_ms, 3)} ms")
    IO.puts("Worst Latency:   #{Float.round(max_ms, 3)} ms")

    if avg_ms < 5.0 do
      IO.puts("\n✅ PASS: FCP is below 5ms target.")
    else
      IO.puts("\n❌ FAIL: FCP exceeded 5ms target.")
    end
  end

  defp flush do
    receive do
      _ -> flush()
    after
      0 -> :ok
    end
  end
end

Aether.BenchmarkFCP.run()
