defmodule Ether.Agents.LintAgent do
  @moduledoc """
  Agent for code quality analysis using Credo.
  Provides structured linting results.
  """
  use GenServer
  require Logger

  @name __MODULE__

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  @doc "Check all files in the project"
  def check_all(opts \\ []) do
    GenServer.call(@name, {:check_all, opts}, :infinity)
  end

  @doc "Check a specific file"
  def check_file(path) do
    GenServer.call(@name, {:check_file, path}, :infinity)
  end

  @doc "Get the last lint results"
  def last_results do
    GenServer.call(@name, :last_results)
  end

  # Server Callbacks

  @impl true
  def init(_state) do
    Logger.info("LintAgent started")
    {:ok, %{last_results: nil}}
  end

  @impl true
  def handle_call({:check_all, opts}, _from, state) do
    result = execute_credo(build_args(opts))
    {:reply, result, %{state | last_results: result}}
  end

  @impl true
  def handle_call({:check_file, path}, _from, state) do
    result = execute_credo(["--files-included", path])
    {:reply, result, %{state | last_results: result}}
  end

  @impl true
  def handle_call(:last_results, _from, state) do
    {:reply, state.last_results, state}
  end

  # Private

  defp execute_credo(args) do
    Logger.info("Running Credo: mix credo #{Enum.join(args, " ")}")
    
    full_args = ["credo", "--format", "json"] ++ args
    
    case System.cmd("mix", full_args, stderr_to_stdout: true, cd: File.cwd!()) do
      {output, 0} ->
        {:ok, parse_credo_output(output, :clean)}
      {output, _exit_code} ->
        {:ok, parse_credo_output(output, :issues_found)}
    end
  end

  defp build_args(opts) do
    opts
    |> Enum.flat_map(fn
      {:strict, true} -> ["--strict"]
      {:all, true} -> ["--all"]
      _ -> []
    end)
  end

  defp parse_credo_output(output, status) do
    # Try to parse JSON output
    case Jason.decode(output) do
      {:ok, %{"issues" => issues}} ->
        %{
          status: status,
          issues: format_issues(issues),
          issue_count: length(issues),
          timestamp: DateTime.utc_now()
        }
      _ ->
        # Fallback for non-JSON output
        %{
          status: status,
          issues: [],
          raw_output: output,
          timestamp: DateTime.utc_now()
        }
    end
  end

  defp format_issues(issues) do
    Enum.map(issues, fn issue ->
      %{
        message: issue["message"],
        category: issue["category"],
        priority: issue["priority"],
        filename: issue["filename"],
        line: issue["line_no"],
        column: issue["column"]
      }
    end)
  end
end
