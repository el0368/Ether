defmodule AetherWeb.EditorChannelAgentTest do
  use AetherWeb.ChannelCase

  alias AetherWeb.EditorChannel

  setup do
    {:ok, _, socket} =
      AetherWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(EditorChannel, "editor:lobby")

    %{socket: socket}
  end

  describe "RefactorAgent Integration" do
    test "refactor:rename returns renamed code", %{socket: socket} do
      code = "def hello, do: :world"
      ref = push(socket, "refactor:rename", %{"code" => code, "old_name" => "hello", "new_name" => "greet"})
      assert_reply ref, :ok, %{code: renamed_code}
      assert renamed_code =~ "def greet, do: :world"
    end
  end

  describe "GitAgent Integration" do
    test "git:status returns status output", %{socket: socket} do
      ref = push(socket, "git:status", %{})
      assert_reply ref, :ok, %{status: status}
      assert is_binary(status)
    end
  end

  describe "CommandAgent Integration" do
    test "cmd:exec runs system command", %{socket: socket} do
      ref = push(socket, "cmd:exec", %{"cmd" => "cmd", "args" => ["/c", "echo", "integration_test"]})
      assert_reply ref, :ok, %{output: output}
      assert output =~ "integration_test"
    end
  end
end
