defmodule Ether.Agents.CommandAgent do
  @moduledoc """
  The Executor of Ether.
  Responsible for running system commands (builds, tests, verifications).
  """
  use Jido.Agent,
    name: "command_agent",
    description: "Safely executes system commands with timeout and logging."


  require Logger

  @default_timeout 30_000 # 30 seconds

  @doc """
  Executes a system command safeley.
  Args:
    - cmd: The command to run (e.g. "mix")
    - args: List of arguments (e.g. ["test"])
    - opts: specific options properly handled (cwd, env, etc)
  """
  def exec(cmd, args, opts \\ []) do
    Logger.debug("CommandAgent: Executing '#{cmd} #{Enum.join(args, " ")}'")
    
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    # Filter out our custom opts before passing to System.cmd
    cmd_opts = Keyword.drop(opts, [:timeout]) |> Keyword.put(:stderr_to_stdout, true)

    task = Task.async(fn -> 
      System.cmd(cmd, args, cmd_opts) 
    end)
    
    case Task.yield(task, timeout) || Task.shutdown(task) do
      {:ok, {output, 0}} -> 
        {:ok, String.trim(output)}
      
      {:ok, {output, code}} ->
        {:error, %{code: code, output: output}}
        
      nil ->
        Logger.warning("CommandAgent: Command timed out")
        {:error, :timeout}
    end
  rescue
    e -> {:error, inspect(e)}
  end
end
