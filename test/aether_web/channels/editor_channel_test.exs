defmodule AetherWeb.EditorChannelTest do
  use AetherWeb.ChannelCase
  
  setup do
    {:ok, _, socket} =
      AetherWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(AetherWeb.EditorChannel, "editor:lobby")

    %{socket: socket}
  end

  test "filetree:list_raw streams chunks and completes", %{socket: socket} do
    # 1. Setup a temp dir
    tmp_dir = System.tmp_dir!() |> Path.join("channel_stream_test_#{System.unique_integer()}")
    File.mkdir_p!(tmp_dir)
    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    # Create enough files to trigger at least one chunk + done
    # NIF chunks at 1000. Let's create 10 files, it will be 1 chunk.
    # To test streaming multiple, we'd need >1000. 
    # Let's trust 10 for basic wiring.
    for i <- 1..10, do: File.write!(Path.join(tmp_dir, "f#{i}"), "c")

    # 2. Push event
    ref = push(socket, "filetree:list_raw", %{"path" => tmp_dir})
    
    # 3. Expect initial generic reply
    assert_reply ref, :ok, %{status: "streaming"}

    # 4. Expect Chunks (push from server)
    # We should receive at least one chunk
    assert_push "filetree:chunk", %{chunk: encoded_chunk}
    
    # Verify we can decode it (basic sanity)
    decoded = Base.decode64!(encoded_chunk)
    assert byte_size(decoded) > 0

    # 5. Expect Done
    assert_push "filetree:done", %{}
  end
end
