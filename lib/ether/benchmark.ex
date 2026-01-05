defmodule Ether.Benchmark do
  @moduledoc """
  Automated Benchmarking Module.
  Runs performance tests and persists history.
  """
  require Logger

  @history_file "bench/history.json"

  def run do
    Task.start(fn ->
      Logger.info("Starting Automated Benchmark...")
      
      # 1. Measure
      elixir_score = measure_ops(fn -> File.ls!(".") end)
      zig_score = measure_ops(fn -> Ether.Scanner.scan_raw(".") end)
      
      result = %{
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
        elixir_ops_sec: elixir_score,
        zig_ops_sec: zig_score
      }

      # 2. Save
      save_history(result)
      
      Logger.info("Benchmark Complete: Elixir=#{elixir_score} ops/s, Zig=#{zig_score} ops/s")
    end)
  end

  defp measure_ops(func, iterations \\ 500) do
    {time_us, _} = :timer.tc(fn ->
      for _ <- 1..iterations, do: func.()
    end)
    
    # Avoid div/0
    time_us = max(time_us, 1)
    
    # Calculate ops/sec
    (iterations / time_us) * 1_000_000
    |> Float.round(2)
  end

  defp save_history(entry) do
    File.mkdir_p!("bench")
    
    history = 
      case File.read(@history_file) do
        {:ok, json} -> 
          case Jason.decode(json) do
            {:ok, list} when is_list(list) -> list
            _ -> []
          end
        _ -> []
      end
    
    # Keep last 100 runs
    new_history = [entry | history] |> Enum.take(100)
    
    File.write!(@history_file, Jason.encode!(new_history, pretty: true))
    
    # OPTIONAL: Write to a data.js file for the HTML report to consume easily
    write_js_data(new_history)
  end

  defp write_js_data(history) do
    json = Jason.encode!(history)
    js_content = "window.BENCHMARK_DATA = #{json};"
    File.write!("bench/data.js", js_content)
  end
end
