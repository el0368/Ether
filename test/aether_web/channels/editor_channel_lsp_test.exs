defmodule AetherWeb.EditorChannelLSPTest do
  use AetherWeb.ChannelCase

  alias AetherWeb.EditorChannel

  setup do
    {:ok, _, socket} =
      AetherWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(EditorChannel, "editor:lobby")

    %{socket: socket}
  end

  describe "LSP Integration" do
    test "lsp:did_open and did_change don't crash", %{socket: socket} do
      push(socket, "lsp:did_open", %{"path" => "lib/foo.ex", "text" => "defmodule Foo do end"})
      push(socket, "lsp:did_change", %{"path" => "lib/foo.ex", "text" => "defmodule Foo do; end"})
      # Assert no crash (process alive)
      assert Process.alive?(socket.channel_pid)
    end

    test "lsp:completion returns suggestions", %{socket: socket} do
      push(socket, "lsp:did_open", %{"path" => "lib/foo.ex", "text" => "defmodule Foo do\n  \nend"})
      ref = push(socket, "lsp:completion", %{"path" => "lib/foo.ex", "line" => 2, "column" => 3})
      assert_reply ref, :ok, %{items: items}, 10_000
      assert is_list(items)
      # Check for our dummy suggestion
      assert Enum.any?(items, fn i -> i.label == "defmodule" end)
    end
  end
end
