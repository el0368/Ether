defmodule Ether.Agents.GitAgent do
  @moduledoc """
  The Historian of Ether.
  Responsible for tracking changes and managing version control.
  """
  use Jido.Agent,
    name: "git_agent",
    description: "Wraps system git commands for safe version control operations."

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end
  
  require Logger

  @doc """
  Gets the current status of the repository.
  Returns {:ok, status_string} or {:error, reason}.
  """
  def status(repo_path \\ ".") do
    run_git(repo_path, ["status", "--porcelain"])
  end
  
  @doc """
  Adds files to the staging area.
  """
  def add(repo_path \\ ".", files) when is_list(files) do
    run_git(repo_path, ["add" | files])
  end

  @doc """
  Commits changes with a message.
  """
  def commit(repo_path \\ ".", message) do
    run_git(repo_path, ["commit", "-m", message])
  end

  # --- Private Helpers ---

  defp run_git(repo_path, args) do
    Logger.debug("GitAgent: Running git #{Enum.join(args, " ")} in #{repo_path}")
    
    opts = [cd: repo_path, stderr_to_stdout: true]
    
    case System.cmd("git", args, opts) do
      {output, 0} -> 
        {:ok, String.trim(output)}
      {output, code} ->
        Logger.error("GitAgent: Command failed (exit #{code}): #{output}")
        {:error, output}
    end
  rescue
    e -> {:error, inspect(e)}
  end
end
