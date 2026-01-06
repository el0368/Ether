# bench/native_scan.exs
defmodule Ether.Benchmark do
  def run do
    # 1. Setup
    count = 10_000
    tmp_dir = System.tmp_dir!() |> Path.join("bench_#{System.unique_integer()}")
    File.mkdir_p!(tmp_dir)
    
    IO.puts("⚡ Preparing Benchmark: Creating #{count} files...")
    {time, _} = :timer.tc(fn ->
      Enum.each(1..count, fn i ->
        File.write!(Path.join(tmp_dir, "file_#{i}.txt"), "content")
      end)
    end)
    IO.puts("   - Setup complete in #{div(time, 1000)}ms")

    # 2. Warmup
    Ether.Native.Scanner.scan_raw(tmp_dir)
    drain_all()

    # 3. Measure
    IO.puts("🚀 Running Native Scan...")
    
    start_time = System.monotonic_time(:millisecond)
    :ok = Ether.Native.Scanner.scan_raw(tmp_dir)
    
    # Wait for completion
    wait_for_done()
    end_time = System.monotonic_time(:millisecond)
    
    duration_ms = end_time - start_time
    throughput = count / (duration_ms / 1000.0)

    IO.puts("\n📊 RESULTS (Level 5 Baseline)")
    IO.puts("   - Files Scanned: #{count}")
    IO.puts("   - Duration: #{duration_ms} ms")
    IO.puts("   - Throughput: #{Float.round(throughput, 2)} files/sec")

    # Cleanup
    File.rm_rf!(tmp_dir)
  end

  defp wait_for_done do
    receive do
      {:scan_completed, :ok} -> :ok
      _ -> wait_for_done()
    after
      10_000 -> 
        IO.puts("❌ Timeout waiting for scan completion")
        exit(:timeout)
    end
  end

  defp drain_all do
    receive do
      _ -> drain_all()
    after
      100 -> :ok
    end
  end
end

Ether.Benchmark.run()
