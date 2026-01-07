defmodule Ether.Benchmark do
  @moduledoc """
  Automated Benchmarking Module with Regression Detection.
  Runs performance tests, persists history, and detects regressions.
  """
  require Logger

  @history_file "bench/history.json"
  @baseline_file "bench/baseline.json"
  @regression_threshold 0.10  # 10% degradation triggers warning

  def run(opts \\ []) do
    Task.start(fn ->
      Logger.info("Starting Automated Benchmark...")
      
      # 1. Measure
      elixir_score = measure_ops(fn -> File.ls!(".") end)
      zig_score = measure_ops(fn -> Ether.Scanner.scan_raw(".") end)
      
      result = %{
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
        elixir_ops_sec: elixir_score,
        zig_ops_sec: zig_score,
        speedup: Float.round(zig_score / elixir_score, 2)
      }

      # 2. Check for regression
      regression_status = check_regression(result)
      
      # 3. Save
      save_history(result)
      
      # 4. Export for CI
      if opts[:ci], do: export_ci_results(result, regression_status)
      
      Logger.info("Benchmark Complete: Elixir=#{elixir_score} ops/s, Zig=#{zig_score} ops/s")
      
      case regression_status do
        {:regression, delta} ->
          Logger.warning("⚠️  Performance regression detected: #{Float.round(delta * 100, 1)}% slower")
        {:improvement, delta} ->
          Logger.info("✅ Performance improvement: #{Float.round(delta * 100, 1)}% faster")
        :no_baseline ->
          Logger.info("📊 No baseline found, setting current as baseline")
          save_baseline(result)
        :ok ->
          Logger.info("✅ Performance within acceptable range")
      end
    end)
  end

  def set_baseline do
    Logger.info("Setting new performance baseline...")
    elixir_score = measure_ops(fn -> File.ls!(".") end)
    zig_score = measure_ops(fn -> Ether.Scanner.scan_raw(".") end)
    
    baseline = %{
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      elixir_ops_sec: elixir_score,
      zig_ops_sec: zig_score,
      speedup: Float.round(zig_score / elixir_score, 2)
    }
    
    save_baseline(baseline)
    Logger.info("✅ Baseline set: Elixir=#{elixir_score} ops/s, Zig=#{zig_score} ops/s")
  end

  defp measure_ops(func, iterations \\ 500) do
    # Warmup
    for _ <- 1..10, do: func.()
    
    {time_us, _} = :timer.tc(fn ->
      for _ <- 1..iterations, do: func.()
    end)
    
    # Avoid div/0
    time_us = max(time_us, 1)
    
    # Calculate ops/sec
    (iterations / time_us) * 1_000_000
    |> Float.round(2)
  end
  
  defp check_regression(current) do
    case load_baseline() do
      nil ->
        :no_baseline
      baseline ->
        # Compare Zig performance (primary metric)
        current_perf = current.zig_ops_sec
        baseline_perf = baseline.zig_ops_sec
        delta = (current_perf - baseline_perf) / baseline_perf
        
        cond do
          delta < -@regression_threshold -> {:regression, abs(delta)}
          delta > @regression_threshold -> {:improvement, delta}
          true -> :ok
        end
    end
  end
  
  defp load_baseline do
    case File.read(@baseline_file) do
      {:ok, json} ->
        case Jason.decode(json, keys: :atoms) do
          {:ok, baseline} -> baseline
          _ -> nil
        end
      _ -> nil
    end
  end
  
  defp save_baseline(baseline) do
    File.mkdir_p!("bench")
    File.write!(@baseline_file, Jason.encode!(baseline, pretty: true))
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
    write_js_data(new_history)
  end

  defp write_js_data(history) do
    json = Jason.encode!(history)
    js_content = "window.BENCHMARK_DATA = #{json};"
    File.write!("bench/data.js", js_content)
  end
  
  defp export_ci_results(result, regression_status) do
    ci_output = %{
      result: result,
      status: regression_status,
      threshold: @regression_threshold
    }
    
    File.write!("bench/ci_results.json", Jason.encode!(ci_output, pretty: true))
    
    # Also write to stdout for GitHub Actions
    IO.puts("::set-output name=zig_ops_sec::#{result.zig_ops_sec}")
    IO.puts("::set-output name=elixir_ops_sec::#{result.elixir_ops_sec}")
    IO.puts("::set-output name=speedup::#{result.speedup}")
    
    case regression_status do
      {:regression, _} -> IO.puts("::set-output name=regression::true")
      _ -> IO.puts("::set-output name=regression::false")
    end
  end
end
