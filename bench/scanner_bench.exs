defmodule Benchmark do
  def measure(name, func, iterations \\ 1000) do
    IO.puts "Measuring #{name} (#{iterations} runs)..."
    {time_us, _result} = :timer.tc(fn ->
      for _ <- 1..iterations, do: func.()
    end)
    
    avg_us = time_us / iterations
    avg_ms = avg_us / 1000
    ops_sec = 1_000_000 / avg_us
    
    IO.puts "  Total: #{time_us / 1000} ms"
    IO.puts "  Avg:   #{avg_us} µs"
    IO.puts "  Rate:  #{Float.round(ops_sec, 2)} ops/sec"
    IO.puts "--------------------------------"
  end
end

Benchmark.measure("Elixir: File.ls (Flat)", fn -> File.ls!(".") end)
Benchmark.measure("Zig: Scanner.scan_raw (Flat)", fn -> Aether.Scanner.scan_raw(".") end)
