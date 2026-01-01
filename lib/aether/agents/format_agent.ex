defmodule Aether.Agents.FormatAgent do
  @moduledoc """
  Agent for code formatting.
  Wraps `mix format` with structured output.
  """
  use GenServer
  require Logger

  @name __MODULE__

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  @doc "Format all files in the project"
  def format_all do
    GenServer.call(@name, :format_all, :infinity)
  end

  @doc "Format a specific file"
  def format_file(path) do
    GenServer.call(@name, {:format_file, path}, :infinity)
  end

  @doc "Check if all files are formatted (without changing them)"
  def check do
    GenServer.call(@name, :check, :infinity)
  end

  @doc "Check if a specific file is formatted"
  def check_file(path) do
    GenServer.call(@name, {:check_file, path}, :infinity)
  end

  # Server Callbacks

  @impl true
  def init(_state) do
    Logger.info("FormatAgent started")
    {:ok, %{last_results: nil}}
  end

  @impl true
  def handle_call(:format_all, _from, state) do
    result = execute_format([])
    {:reply, result, %{state | last_results: result}}
  end

  @impl true
  def handle_call({:format_file, path}, _from, state) do
    result = execute_format([path])
    {:reply, result, %{state | last_results: result}}
  end

  @impl true
  def handle_call(:check, _from, state) do
    result = execute_format(["--check-formatted"])
    {:reply, result, %{state | last_results: result}}
  end

  @impl true
  def handle_call({:check_file, path}, _from, state) do
    result = execute_format(["--check-formatted", path])
    {:reply, result, %{state | last_results: result}}
  end

  # Private

  defp execute_format(args) do
    Logger.info("Running format: mix format #{Enum.join(args, " ")}")
    
    case System.cmd("mix", ["format"] ++ args, stderr_to_stdout: true, cd: File.cwd!()) do
      {_output, 0} ->
        {:ok, %{
          status: :formatted,
          files_changed: count_formatted_files(args),
          timestamp: DateTime.utc_now()
        }}
      {output, 1} ->
        # Exit code 1 means files need formatting (when using --check-formatted)
        {:error, %{
          status: :needs_formatting,
          output: output,
          files: parse_unformatted_files(output),
          timestamp: DateTime.utc_now()
        }}
      {output, _} ->
        {:error, %{
          status: :error,
          output: output,
          timestamp: DateTime.utc_now()
        }}
    end
  end

  defp count_formatted_files(args) do
    # If formatting specific files, count them
    args
    |> Enum.reject(&String.starts_with?(&1, "--"))
    |> length()
    |> case do
      0 -> :all
      n -> n
    end
  end

  defp parse_unformatted_files(output) do
    # Parse output for file paths
    output
    |> String.split("\n")
    |> Enum.filter(&String.contains?(&1, ".ex"))
    |> Enum.map(&String.trim/1)
  end
end
