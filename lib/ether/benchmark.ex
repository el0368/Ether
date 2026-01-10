defmodule Ether.Benchmark do
  @moduledoc """
  Automated Benchmarking Module with Regression Detection.
  Runs performance tests, persists history, and detects regressions.
  """
  require Logger

  @history_file "bench/history.json"
  @baseline_file "bench/baseline.json"
  # 10% degradation triggers warning
  @regression_threshold 0.10

  def run(opts \\ []) do
    Task.start(fn -> do_run(opts) end)
  end

  def run_sync(opts \\ []) do
    do_run(opts)
  end

  @doc """
  Records a map of metrics and persists them to history.
  Accepts a flat map of key-value pairs.
  """
  def record_metrics(metrics) when is_map(metrics) do
    entry =
      Map.merge(metrics, %{
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
      })

    save_history(entry)
  end

  defp do_run(opts) do
    Logger.info("Starting Automated Scanner Benchmark...")

    # Measure Scanner (Legacy compatible path)
    {elixir_score, elixir_count} = measure_ops_with_count(fn -> elixir_recursive_scan(".") end)
    {zig_score, zig_count} = measure_ops_with_count(fn -> Ether.Scanner.scan_raw(".") end)

    IO.puts(
      "[info] Work Verification: Elixir found #{elixir_count} files, Zig found #{zig_count} files"
    )

    result = %{
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      elixir_ops_sec: elixir_score,
      zig_ops_sec: zig_score,
      speedup: Float.round(zig_score / elixir_score, 2),
      metric_type: "scanner"
    }

    # Check for regression (only for scanner)
    regression_status = check_regression(result)

    # Save
    save_history(result)

    # Export for CI
    if opts[:ci], do: export_ci_results(result, regression_status)

    Logger.info("Benchmark Complete: Elixir=#{elixir_score} ops/s, Zig=#{zig_score} ops/s")

    case regression_status do
      {:regression, delta} ->
        Logger.warning(
          "⚠️  Performance regression detected: #{Float.round(delta * 100, 1)}% slower"
        )

      {:improvement, delta} ->
        Logger.info("✅ Performance improvement: #{Float.round(delta * 100, 1)}% faster")

      :no_baseline ->
        Logger.info("📊 No baseline found, setting current as baseline")
        save_baseline(result)

      :ok ->
        Logger.info("✅ Performance within acceptable range")
    end
  end

  def set_baseline do
    Logger.info("Setting new performance baseline...")
    {elixir_score, _} = measure_ops_with_count(fn -> elixir_recursive_scan(".") end)
    {zig_score, _} = measure_ops_with_count(fn -> Ether.Scanner.scan_raw(".") end)

    baseline = %{
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      elixir_ops_sec: elixir_score,
      zig_ops_sec: zig_score,
      speedup: Float.round(zig_score / elixir_score, 2),
      metric_type: "scanner"
    }

    save_baseline(baseline)
    Logger.info("✅ Baseline set: Elixir=#{elixir_score} ops/s, Zig=#{zig_score} ops/s")
  end

  defp measure_ops_with_count(func, iterations \\ 5) do
    # Warmup
    for _ <- 1..3, do: func.()

    # Get a sample count
    sample_list = func.()

    count =
      case sample_list do
        list when is_list(list) -> length(list)
        {:ok, count} -> count
        other -> other
      end

    {time_us, _} =
      :timer.tc(fn ->
        for _ <- 1..iterations, do: func.()
      end)

    time_us = max(time_us, 1)
    score = Float.round(iterations / time_us * 1_000_000, 2)
    {score, count}
  end

  defp elixir_recursive_scan(path) do
    basename = Path.basename(path)

    if basename in [".git", "_build", "deps", ".elixir_ls", "node_modules"] do
      []
    else
      if File.dir?(path) do
        case File.ls(path) do
          {:ok, entries} ->
            Enum.flat_map(entries, fn entry ->
              elixir_recursive_scan(Path.join(path, entry))
            end)

          _ ->
            []
        end
      else
        [path]
      end
    end
  end

  defp check_regression(current) do
    case load_baseline() do
      nil ->
        :no_baseline

      baseline ->
        # Only compare if types match
        if current[:metric_type] == baseline[:metric_type] do
          # Compare Zig performance (primary metric for scanner)
          current_perf = current.zig_ops_sec
          baseline_perf = baseline.zig_ops_sec
          delta = (current_perf - baseline_perf) / baseline_perf

          cond do
            delta < -@regression_threshold -> {:regression, abs(delta)}
            delta > @regression_threshold -> {:improvement, delta}
            true -> :ok
          end
        else
          :ok
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

      _ ->
        nil
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

        _ ->
          []
      end

    # Unified history management
    unified_history =
      case history do
        list when is_list(list) ->
          # If it's a list, check if it's the old flat list or new typed entries
          # We'll just append and tag with metric_type if missing
          [entry | list]

        _ ->
          [entry]
      end

    # Keep last 200 runs (multiple tiers mean more entries)
    final_history = Enum.take(unified_history, 200)

    File.write!(@history_file, Jason.encode!(final_history, pretty: true))
    write_js_data(final_history)
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

    # Also write to stdout for GitHub Actions if metric_type is scanner
    if result[:metric_type] == "scanner" do
      IO.puts("::set-output name=zig_ops_sec::#{result.zig_ops_sec}")
      IO.puts("::set-output name=elixir_ops_sec::#{result.elixir_ops_sec}")
      IO.puts("::set-output name=speedup::#{result.speedup}")

      case regression_status do
        {:regression, _} -> IO.puts("::set-output name=regression::true")
        _ -> IO.puts("::set-output name=regression::false")
      end
    end
  end
end
