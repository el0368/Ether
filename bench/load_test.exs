defmodule LoadTest do
  @moduledoc """
  Load testing suite for Ether IDE.
  Tests concurrent operations, sustained load, and spike scenarios.
  """
  
  require Logger

  def run do
    IO.puts("\n🔥 Load Testing Suite")
    IO.puts("=" |> String.duplicate(50))
    
    test_concurrent_scans()
    test_concurrent_searches()
    test_mixed_workload()
    test_sustained_load()
    test_spike_scenario()
    
    IO.puts("\n✅ Load Testing Complete")
  end
  
  defp test_concurrent_scans do
    IO.puts("\n📊 Concurrent Scans")
    
    for concurrency <- [10, 50, 100] do
      IO.write("  #{concurrency} parallel scans... ")
      
      {time_ms, results} = :timer.tc(fn ->
        tasks = for _ <- 1..concurrency do
          Task.async(fn ->
            Ether.Scanner.scan_raw(".")
            flush_messages()
            :ok
          end)
        end
        
        Task.await_many(tasks, 30_000)
      end)
      
      time_ms = time_ms / 1000
      success_count = Enum.count(results, &(&1 == :ok))
      throughput = concurrency / (time_ms / 1000)
      
      IO.puts("#{time_ms}ms | #{success_count}/#{concurrency} OK | #{Float.round(throughput, 1)} scans/sec")
    end
  end
  
  defp test_concurrent_searches do
    IO.puts("\n🔍 Concurrent Searches")
    
    # Ensure context exists
    {:ok, ctx} = Ether.Native.Scanner.create_context()
    
    for concurrency <- [10, 50, 100] do
      IO.write("  #{concurrency} parallel searches... ")
      
      {time_ms, results} = :timer.tc(fn ->
        tasks = for i <- 1..concurrency do
          Task.async(fn ->
            query = if rem(i, 2) == 0, do: "defmodule", else: "def "
            Ether.Native.Scanner.search(ctx, query, "lib")
          end)
        end
        
        Task.await_many(tasks, 30_000)
      end)
      
      time_ms = time_ms / 1000
      success_count = Enum.count(results, &match?({:ok, _}, &1))
      throughput = concurrency / (time_ms / 1000)
      
      IO.puts("#{time_ms}ms | #{success_count}/#{concurrency} OK | #{Float.round(throughput, 1)} searches/sec")
    end
    
    Ether.Native.Scanner.close_context(ctx)
  end
  
  defp test_mixed_workload do
    IO.puts("\n⚡ Mixed Workload (Scan + Search)")
    IO.write("  50 scans + 50 searches... ")
    
    {time_ms, results} = :timer.tc(fn ->
      scan_tasks = for _ <- 1..50 do
        Task.async(fn ->
          Ether.Scanner.scan_raw(".")
          flush_messages()
          :scan_ok
        end)
      end
      
      search_tasks = for _ <- 1..50 do
        Task.async(fn ->
          {:ok, ctx} = Ether.Native.Scanner.create_context()
          result = Ether.Native.Scanner.search(ctx, "defmodule", "lib")
          Ether.Native.Scanner.close_context(ctx)
          {:search_ok, result}
        end)
      end
      
      Task.await_many(scan_tasks ++ search_tasks, 60_000)
    end)
    
    time_ms = time_ms / 1000
    scans = Enum.count(results, &(&1 == :scan_ok))
    searches = Enum.count(results, &match?({:search_ok, _}, &1))
    
    IO.puts("#{time_ms}ms | Scans: #{scans}/50 | Searches: #{searches}/50")
  end
  
  defp test_sustained_load do
    IO.puts("\n⏱️  Sustained Load (30 seconds)")
    IO.write("  Continuous operations... ")
    
    end_time = System.monotonic_time(:millisecond) + 30_000
    count = sustained_loop(end_time, 0)
    
    throughput = count / 30.0
    IO.puts("#{count} operations | #{Float.round(throughput, 1)} ops/sec")
  end
  
  defp sustained_loop(end_time, count) do
    if System.monotonic_time(:millisecond) < end_time do
      Ether.Scanner.scan_raw(".")
      flush_messages()
      sustained_loop(end_time, count + 1)
    else
      count
    end
  end
  
  defp test_spike_scenario do
    IO.puts("\n📈 Spike Scenario")
    IO.write("  Baseline (10 ops) → Spike (100 ops) → Recovery (10 ops)... ")
    
    # Baseline
    {baseline_ms, _} = :timer.tc(fn ->
      for _ <- 1..10 do
        Ether.Scanner.scan_raw(".")
        flush_messages()
      end
    end)
    
    # Spike
    {spike_ms, _} = :timer.tc(fn ->
      tasks = for _ <- 1..100 do
        Task.async(fn ->
          Ether.Scanner.scan_raw(".")
          flush_messages()
        end)
      end
      Task.await_many(tasks, 60_000)
    end)
    
    # Recovery
    {recovery_ms, _} = :timer.tc(fn ->
      for _ <- 1..10 do
        Ether.Scanner.scan_raw(".")
        flush_messages()
      end
    end)
    
    baseline_ms = baseline_ms / 1000
    spike_ms = spike_ms / 1000
    recovery_ms = recovery_ms / 1000
    
    IO.puts("Baseline: #{baseline_ms}ms | Spike: #{spike_ms}ms | Recovery: #{recovery_ms}ms")
  end
  
  defp flush_messages do
    receive do
      _ -> flush_messages()
    after
      0 -> :ok
    end
  end
end

# Run if executed directly
if System.argv() == [] do
  LoadTest.run()
end
