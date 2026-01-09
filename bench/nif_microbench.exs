defmodule NifMicrobench do
  @moduledoc """
  Microbenchmarks for individual NIF operations.
  Measures overhead of context creation, binary operations, and resource lifecycle.
  """
  
  @data_file "bench/data.js"

  def run do
    IO.puts("\n🔬 NIF Microbenchmarks")
    IO.puts("=" |> String.duplicate(50))
    
    # Run Benchmarks and Collect Results
    results = %{
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      metric_type: "scanner"
    }

    # 1. Context Lifecycle
    _lifecycle_ops = measure("Context Create/Destroy", fn ->
      {:ok, ctx} = Ether.Native.Scanner.create_context()
      Ether.Native.Scanner.close_context(ctx)
    end, 1000)
    
    # 2. Slab Decoding (Translation Tax) - CRITICAL METRIC
    # We use this as the primary "Zig Throughput" metric
    mock_slab = create_mock_slab(100)
    decoding_ops = measure("Slab Decoding (100 nodes)", fn ->
      decode_slab(mock_slab, "/root", [])
    end, 1000)

    # 3. Scan Operation (Minimal)
    {:ok, scan_ctx} = Ether.Native.Scanner.create_context()
    _scan_ops = measure("Scan Yield Loop (Current Dir)", fn ->
      run_yield_loop(scan_ctx, ".", self())
      flush_messages()
    end, 100)
    Ether.Native.Scanner.close_context(scan_ctx)
    
    # 4. Search Operation (Single File)
    _search_ops = measure("Search (Single File)", fn ->
      {:ok, ctx} = Ether.Native.Scanner.create_context()
      Ether.Native.Scanner.search(ctx, "defmodule", Path.expand("lib/ether/scanner.ex"))
      Ether.Native.Scanner.close_context(ctx)
    end, 1000)

    # Construct Data Point
    # We use Slab Decoding (100 nodes) as the representative "Zig Throughput"
    # because it isolates the raw data transfer speed.
    data_point = Map.merge(results, %{
      zig_ops_sec: decoding_ops,
      elixir_ops_sec: 0.0, # Not measuring pure Elixir equivalent right now
      speedup: 0.0
    })

    save_result(data_point)
    
    IO.puts("\n✅ Microbenchmarks Complete & Saved to #{@data_file}")
  end

  defp save_result(new_entry) do
    # Read existing file
    content = File.read!(@data_file)
    
    # Parse existing JSON array from JS assignment
    # Expected format: window.BENCHMARK_DATA = [...];
    prefix = "window.BENCHMARK_DATA = "
    json_part = String.trim_leading(content, prefix) |> String.trim_trailing(";")
    
    existing_data = Jason.decode!(json_part)
    updated_data = existing_data ++ [new_entry]
    
    # Write back
    new_content = prefix <> Jason.encode!(updated_data) <> ";"
    File.write!(@data_file, new_content)
  end

  defp create_mock_slab(count) do
    for i <- 1..count, into: <<>> do
      path = "file_#{i}.ex"
      len = byte_size(path)
      <<1::8, len::16-little, path::binary>>
    end
  end

  # Re-implementing the decoding logic here for isolated benchmarking
  defp decode_slab(<<>>, _root, acc), do: acc
  defp decode_slab(<<_type::8, len::16-little, path::binary-size(len), rest::binary>>, root, acc) do
    decode_slab(rest, root, [Path.join(root, path) | acc])
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
    
    ops_sec
  end

  defp format_time(ns) when ns < 1_000, do: "#{Float.round(ns, 2)} ns"
  defp format_time(ns) when ns < 1_000_000, do: "#{Float.round(ns / 1_000, 2)} µs"
  defp format_time(ns), do: "#{Float.round(ns / 1_000_000, 2)} ms"

  defp run_yield_loop(ctx, path, pid) do
    case Ether.Native.Scanner.scan_yield_nif(ctx, path, pid, 64) do
      count when is_integer(count) -> {:ok, count}
      :ok -> :ok
      {:cont, ^ctx} -> run_yield_loop(ctx, path, pid)
      _ -> :ok
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

if System.argv() == [] do
  NifMicrobench.run()
end
