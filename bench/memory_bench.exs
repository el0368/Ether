defmodule MemoryBench do
  @moduledoc """
  Memory profiling benchmark for Ether IDE.
  Tracks memory usage, detects leaks, and measures allocation patterns.
  """
  
  require Logger

  def run do
    IO.puts("\n💾 Memory Profiling")
    IO.puts("=" |> String.duplicate(50))
    
    test_scan_memory()
    test_search_memory()
    test_context_lifecycle_memory()
    test_leak_detection()
    
    IO.puts("\n✅ Memory Profiling Complete")
  end
  
  defp test_scan_memory do
    IO.puts("\n📊 Scan Memory Usage")
    
    # Force GC
    :erlang.garbage_collect()
    Process.sleep(100)
    
    mem_before = :erlang.memory(:total)
    
    # Perform scans
    for _ <- 1..100 do
      Ether.Scanner.scan_raw(".")
      flush_messages()
    end
    
    # Force GC again
    :erlang.garbage_collect()
    Process.sleep(100)
    
    mem_after = :erlang.memory(:total)
    mem_delta = mem_after - mem_before
    
    IO.puts("  Before: #{format_bytes(mem_before)}")
    IO.puts("  After:  #{format_bytes(mem_after)}")
    IO.puts("  Delta:  #{format_bytes(mem_delta)} (#{if mem_delta > 0, do: "+", else: ""}#{Float.round(mem_delta / mem_before * 100, 2)}%)")
  end
  
  defp test_search_memory do
    IO.puts("\n🔍 Search Memory Usage")
    
    :erlang.garbage_collect()
    Process.sleep(100)
    
    mem_before = :erlang.memory(:total)
    
    {:ok, ctx} = Ether.Native.Scanner.create_context()
    
    for _ <- 1..100 do
      Ether.Native.Scanner.search(ctx, "defmodule", "lib")
    end
    
    Ether.Native.Scanner.close_context(ctx)
    
    :erlang.garbage_collect()
    Process.sleep(100)
    
    mem_after = :erlang.memory(:total)
    mem_delta = mem_after - mem_before
    
    IO.puts("  Before: #{format_bytes(mem_before)}")
    IO.puts("  After:  #{format_bytes(mem_after)}")
    IO.puts("  Delta:  #{format_bytes(mem_delta)} (#{if mem_delta > 0, do: "+", else: ""}#{Float.round(mem_delta / mem_before * 100, 2)}%)")
  end
  
  defp test_context_lifecycle_memory do
    IO.puts("\n🔄 Context Lifecycle Memory")
    
    :erlang.garbage_collect()
    Process.sleep(100)
    
    mem_before = :erlang.memory(:total)
    
    # Create and destroy many contexts
    for _ <- 1..1000 do
      {:ok, ctx} = Ether.Native.Scanner.create_context()
      Ether.Native.Scanner.close_context(ctx)
    end
    
    :erlang.garbage_collect()
    Process.sleep(100)
    
    mem_after = :erlang.memory(:total)
    mem_delta = mem_after - mem_before
    
    IO.puts("  Before: #{format_bytes(mem_before)}")
    IO.puts("  After:  #{format_bytes(mem_after)}")
    IO.puts("  Delta:  #{format_bytes(mem_delta)} (#{if mem_delta > 0, do: "+", else: ""}#{Float.round(mem_delta / mem_before * 100, 2)}%)")
    
    if mem_delta > 1_000_000 do
      IO.puts("  ⚠️  WARNING: Potential memory leak detected (>1MB growth)")
    else
      IO.puts("  ✅ No significant memory leak detected")
    end
  end
  
  defp test_leak_detection do
    IO.puts("\n🔬 Leak Detection (Sustained Operations)")
    
    samples = []
    
    for i <- 1..10 do
      :erlang.garbage_collect()
      Process.sleep(50)
      
      mem_before = :erlang.memory(:total)
      
      # Perform operations
      for _ <- 1..50 do
        Ether.Scanner.scan_raw(".")
        flush_messages()
      end
      
      :erlang.garbage_collect()
      Process.sleep(50)
      
      mem_after = :erlang.memory(:total)
      delta = mem_after - mem_before
      
      samples = [delta | samples]
      
      IO.puts("  Iteration #{i}: #{format_bytes(delta)} delta")
    end
    
    # Analyze trend
    avg_delta = Enum.sum(samples) / length(samples)
    
    if avg_delta > 500_000 do
      IO.puts("\n  ⚠️  WARNING: Average delta >500KB, possible leak")
    else
      IO.puts("\n  ✅ Memory usage stable (avg delta: #{format_bytes(trunc(avg_delta))})")
    end
  end
  
  defp format_bytes(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_bytes(bytes) when bytes < 1024 * 1024, do: "#{Float.round(bytes / 1024, 2)} KB"
  defp format_bytes(bytes) when bytes < 1024 * 1024 * 1024, do: "#{Float.round(bytes / (1024 * 1024), 2)} MB"
  defp format_bytes(bytes), do: "#{Float.round(bytes / (1024 * 1024 * 1024), 2)} GB"
  
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
  MemoryBench.run()
end
