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
    end, 10_000)
    
    # 2. Binary Decoding (Small)
    small_binary = <<1, 0, 5, "hello">>
    measure("Binary Decode (Small)", fn ->
      Ether.Native.NifDecoder.decode_entry(small_binary, 0)
    end, 50_000)
    
    # 3. Binary Decoding (Medium)
    medium_binary = create_test_binary(100)
    measure("Binary Decode (Medium)", fn ->
      Ether.Native.NifDecoder.decode_all(medium_binary)
    end, 10_000)
    
    # 4. Binary Decoding (Large)
    large_binary = create_test_binary(1000)
    measure("Binary Decode (Large)", fn ->
      Ether.Native.NifDecoder.decode_all(large_binary)
    end, 1_000)
    
    # 5. Scan Operation (Minimal)
    measure("Scan (Current Dir)", fn ->
      Ether.Scanner.scan_raw(".")
      flush_messages()
    end, 100)
    
    # 6. Search Operation (Small file)
    measure("Search (Single File)", fn ->
      {:ok, ctx} = Ether.Native.Scanner.create_context()
      Ether.Native.Scanner.search(ctx, "defmodule", "lib/ether/benchmark.ex")
      Ether.Native.Scanner.close_context(ctx)
    end, 1_000)
    
    IO.puts("\n✅ Microbenchmarks Complete")
  end
  
  defp measure(name, func, iterations) do
    IO.write("#{name} (#{iterations} runs)... ")
    
    # Warmup
    for _ <- 1..10, do: func.()
    
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
  
  defp create_test_binary(entries) do
    for i <- 1..entries, into: <<>> do
      path = "test/file_#{i}.ex"
      type = if rem(i, 2) == 0, do: 1, else: 0
      <<type::8, byte_size(path)::16, path::binary>>
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
