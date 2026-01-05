defmodule Ether.Agents.GitAgentTest do
  use ExUnit.Case, async: false # Git operations are stateful
  alias Ether.Agents.GitAgent

  # use a temporary directory for git tests
  @moduletag :tmp_dir

  test "initializes and checks status", %{tmp_dir: dir} do
    # Init git repo
    File.cd!(dir, fn -> 
      System.cmd("git", ["init"])
      System.cmd("git", ["config", "user.email", "test@example.com"])
      System.cmd("git", ["config", "user.name", "Test User"])
    end)

    # Status should be empty
    assert {:ok, ""} = GitAgent.status(dir)

    # Create a file
    File.write!(Path.join(dir, "test.txt"), "hello")

    # Status should show untracked file
    {:ok, status} = GitAgent.status(dir)
    assert status =~ "?? test.txt"
  end

  test "commits changes", %{tmp_dir: dir} do
    File.cd!(dir, fn -> 
      System.cmd("git", ["init"]) 
      System.cmd("git", ["config", "user.email", "test@example.com"])
      System.cmd("git", ["config", "user.name", "Test User"])
    end)

    File.write!(Path.join(dir, "readme.md"), "# Hello")

    assert {:ok, _} = GitAgent.add(dir, ["readme.md"])
    assert {:ok, output} = GitAgent.commit(dir, "feat: Initial commit")
    
    assert output =~ "Initial commit"
    assert output =~ "1 file changed"
  end
end
