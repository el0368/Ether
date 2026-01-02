defmodule Aether.Agents.CommandAgentTest do
  use ExUnit.Case, async: true
  alias Aether.Agents.CommandAgent

  test "executes simple command successfully" do
    # echo works on both windows and linux/mac usually, but "cmd /c echo" or just echo depending on environment.
    # We'll use "erl" -version or something safe. Or just "cmd" /c echo hello on windows.
    # Given we are on windows.
    
    assert {:ok, output} = CommandAgent.exec("cmd", ["/c", "echo", "hello"])
    assert output =~ "hello"
  end

  test "handles failure exit codes" do
    # exit 1
    assert {:error, %{code: 1}} = CommandAgent.exec("cmd", ["/c", "exit", "1"])
  end

  test "handles timeouts" do
    # timeout is 30s by default, but we can pass small timeout
    # ping -n 3 127.0.0.1 takes > 2 seconds
    
    assert {:error, :timeout} = CommandAgent.exec("ping", ["-n", "3", "127.0.0.1"], timeout: 100)
  end
end
