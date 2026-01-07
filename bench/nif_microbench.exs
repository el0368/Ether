defmodule NifMicrobench do
  @moduledoc """
  Microbenchmarks for individual NIF operations.
  Measures overhead of context creation, binary operations, and resource lifecycle.
  """

  def run do
    IO.puts("\n🔬 NIF Microbenchmarks")
    IO.puts("=" |> String.duplicate(50))
    
    # 1. Context Lifecycle
    measure("Context Create/Destroy", fn ->
      {:ok, ctx} = Ether.Native.Scanner.create_context()
      Ether.Native.Scanner.close_context(ctx)
    end, 1000)
    
    # 2. Binary Decoding (Small) - DISABLED (Missing NifDecoder)
    # small_binary = <<1, 0, 5, "hello">>
    # measure("Binary Decode (Small)", fn ->
    #   Ether.Native.NifDecoder.decode_entry(small_binary, 0)
    # end, 50_000)
    
    # 3. Binary Decoding (Medium) - DISABLED (Missing NifDecoder)
    # medium_binary = create_test_binary(100)
    # measure("Binary Decode (Medium)", fn ->
    #   Ether.Native.NifDecoder.decode_all(medium_binary)
    # end, 10_000)
    
    # 4. Binary Decoding (Large) - DISABLED (Missing NifDecoder)
    # large_binary = create_test_binary(1000)
    # measure("Binary Decode (Large)", fn ->
    #   Ether.Native.NifDecoder.decode_all(large_binary)
    # end, 1_000)
    
    # 5. Scan Operation (Minimal)
    # 5. Scan Operation (Minimal)
    {:ok, scan_ctx} = Ether.Native.Scanner.create_context()
    measure("Scan (Current Dir)", fn ->
      run_yield_loop(scan_ctx, ".", self())
      flush_messages()
    end, 100)
    Ether.Native.Scanner.close_context(scan_ctx)
    
    # 6. Search Operation (Small file)
    measure("Search (Single File)", fn ->
      {:ok, ctx} = Ether.Native.Scanner.create_context()
      Ether.Native.Scanner.search(ctx, "defmodule", Path.expand("lib/ether/benchmark.ex"))
      Ether.Native.Scanner.close_context(ctx)
    end, 1000)
    
    IO.puts("\n✅ Microbenchmarks Complete")
  end
  
  defp measure(name, func, iterations) do
    IO.write("#{name} (#{iterations} runs)... ")
    
    # Warmup
    for _ <- 1..5, do: func.()
    
    # Measure
    {time_us, _} = :timer.tc(fn ->
      for _ <- 1..iterations, do: func.()
    end)
    
    avg_us = time_us / iterations
    avg_ns = avg_us * 1000
    ops_sec = (iterations / time_us) * 1_000_000
    
    IO.puts("#{format_time(avg_ns)} | #{Float.round(ops_sec, 0)} ops/sec")
  end
  
  defp format_time(ns) when ns < 1_000, do: "#{Float.round(ns, 2)} ns"
  defp format_time(ns) when ns < 1_000_000, do: "#{Float.round(ns / 1_000, 2)} µs"
  defp format_time(ns), do: "#{Float.round(ns / 1_000_000, 2)} ms"
  
  
  defp run_yield_loop(ctx, path, pid) do
    case Ether.Native.Scanner.scan_yield_nif(ctx, path, pid) do
      :ok -> :ok
      {:cont, ^ctx} -> run_yield_loop(ctx, path, pid)
    end
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
  NifMicrobench.run()
end
