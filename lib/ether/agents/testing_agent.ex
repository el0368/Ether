defmodule Ether.Agents.TestingAgent do
  @moduledoc """
  Agent for running tests and tracking test results.
  Wraps `mix test` with structured output.
  """
  use GenServer
  require Logger

  @name __MODULE__

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  @doc "Run all tests in the project"
  def run_all(opts \\ []) do
    GenServer.call(@name, {:run_all, opts}, :infinity)
  end

  @doc "Run tests for a specific file"
  def run_file(path) do
    GenServer.call(@name, {:run_file, path}, :infinity)
  end

  @doc "Get the last test results"
  def last_results do
    GenServer.call(@name, :last_results)
  end

  # Server Callbacks

  @impl true
  def init(_state) do
    Logger.info("TestingAgent started")
    {:ok, %{last_results: nil, running: false}}
  end

  @impl true
  def handle_call({:run_all, opts}, _from, state) do
    result = execute_tests(["test"] ++ build_opts(opts))
    {:reply, result, %{state | last_results: result}}
  end

  @impl true
  def handle_call({:run_file, path}, _from, state) do
    result = execute_tests(["test", path])
    {:reply, result, %{state | last_results: result}}
  end

  @impl true
  def handle_call(:last_results, _from, state) do
    {:reply, state.last_results, state}
  end

  # Private

  defp execute_tests(args) do
    Logger.info("Running tests: mix #{Enum.join(args, " ")}")
    
    case System.cmd("mix", args, stderr_to_stdout: true, cd: File.cwd!()) do
      {output, 0} ->
        {:ok, parse_test_output(output, :passed)}
      {output, _exit_code} ->
        {:error, parse_test_output(output, :failed)}
    end
  end

  defp build_opts(opts) do
    opts
    |> Enum.flat_map(fn
      {:cover, true} -> ["--cover"]
      {:trace, true} -> ["--trace"]
      {:seed, seed} -> ["--seed", to_string(seed)]
      _ -> []
    end)
  end

  defp parse_test_output(output, status) do
    # Parse test output for structured results
    lines = String.split(output, "\n")
    
    # Look for summary line like "5 tests, 0 failures"
    summary = Enum.find(lines, fn line -> 
      String.contains?(line, "test") && String.contains?(line, "failure")
    end)

    %{
      status: status,
      output: output,
      summary: summary || "No summary found",
      timestamp: DateTime.utc_now()
    }
  end
end
