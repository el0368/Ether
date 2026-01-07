defmodule WebVitalsBench do
  @moduledoc """
  Web Vitals benchmark for Ether IDE.
  Measures frontend performance metrics for both desktop and browser modes.
  """
  
  require Logger

  def run do
    IO.puts("\n🌐 Web Vitals Benchmark")
    IO.puts("=" |> String.duplicate(50))
    
    test_ttfb()
    test_fcp()
    test_tti()
    
    IO.puts("\n✅ Web Vitals Complete")
    IO.puts("\n💡 For full Core Web Vitals (LCP, FID, CLS), open the app in browser")
    IO.puts("   and check the browser console for performance metrics.")
  end
  
  defp test_ttfb do
    IO.puts("\n⚡ Time to First Byte (TTFB)")
    
    # Test Phoenix endpoint response time
    measurements = for _ <- 1..10 do
      t0 = System.monotonic_time(:microsecond)
      
      # Simulate HTTP request to Phoenix
      case HTTPoison.get("http://localhost:4000") do
        {:ok, _response} ->
          t1 = System.monotonic_time(:microsecond)
          t1 - t0
        {:error, _} ->
          IO.puts("  ⚠️  Server not running on localhost:4000")
          nil
      end
    end
    
    valid_measurements = Enum.reject(measurements, &is_nil/1)
    
    if Enum.empty?(valid_measurements) do
      IO.puts("  ❌ Could not measure TTFB (server not running)")
    else
      avg_us = Enum.sum(valid_measurements) / length(valid_measurements)
      min_us = Enum.min(valid_measurements)
      max_us = Enum.max(valid_measurements)
      
      IO.puts("  Average: #{format_time(avg_us)}")
      IO.puts("  Best:    #{format_time(min_us)}")
      IO.puts("  Worst:   #{format_time(max_us)}")
      
      if avg_us / 1000 < 100 do
        IO.puts("  ✅ Excellent (<100ms)")
      else
        IO.puts("  ⚠️  Could be improved (target: <100ms)")
      end
    end
  end
  
  defp test_fcp do
    IO.puts("\n🎨 First Contentful Paint (FCP Proxy)")
    IO.puts("  Measuring time to first scanner chunk...")
    
    measurements = for _ <- 1..10 do
      t0 = System.monotonic_time(:microsecond)
      
      :ok = Ether.Scanner.scan_raw(".")
      
      receive do
        {:scanner_chunk, _} ->
          t1 = System.monotonic_time(:microsecond)
          flush_messages()
          t1 - t0
      after
        1000 ->
          flush_messages()
          nil
      end
    end
    
    valid_measurements = Enum.reject(measurements, &is_nil/1)
    
    if Enum.empty?(valid_measurements) do
      IO.puts("  ❌ Could not measure FCP")
    else
      avg_us = Enum.sum(valid_measurements) / length(valid_measurements)
      min_us = Enum.min(valid_measurements)
      max_us = Enum.max(valid_measurements)
      
      IO.puts("  Average: #{format_time(avg_us)}")
      IO.puts("  Best:    #{format_time(min_us)}")
      IO.puts("  Worst:   #{format_time(max_us)}")
      
      avg_ms = avg_us / 1000
      
      cond do
        avg_ms < 1.8 -> IO.puts("  ✅ Excellent (<1.8s)")
        avg_ms < 3.0 -> IO.puts("  ⚠️  Good (<3.0s)")
        true -> IO.puts("  ❌ Needs improvement (>3.0s)")
      end
    end
  end
  
  defp test_tti do
    IO.puts("\n⏱️  Time to Interactive (TTI Proxy)")
    IO.puts("  Measuring time until system is responsive...")
    
    # Simulate app startup sequence
    t0 = System.monotonic_time(:microsecond)
    
    # 1. Create context
    {:ok, ctx} = Ether.Native.Scanner.create_context()
    
    # 2. Perform initial scan
    :ok = Ether.Scanner.scan_raw(".")
    flush_messages()
    
    # 3. System is now "interactive"
    t1 = System.monotonic_time(:microsecond)
    
    Ether.Native.Scanner.close_context(ctx)
    
    tti_us = t1 - t0
    tti_ms = tti_us / 1000
    
    IO.puts("  TTI: #{format_time(tti_us)}")
    
    cond do
      tti_ms < 3800 -> IO.puts("  ✅ Excellent (<3.8s)")
      tti_ms < 7300 -> IO.puts("  ⚠️  Good (<7.3s)")
      true -> IO.puts("  ❌ Needs improvement (>7.3s)")
    end
  end
  
  defp format_time(us) when us < 1_000, do: "#{Float.round(us, 2)} µs"
  defp format_time(us) when us < 1_000_000, do: "#{Float.round(us / 1_000, 2)} ms"
  defp format_time(us), do: "#{Float.round(us / 1_000_000, 2)} s"
  
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
  WebVitalsBench.run()
end
