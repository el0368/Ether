defmodule EtherWeb.EditorChannelTest do
  use EtherWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      EtherWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(EtherWeb.EditorChannel, "editor:lobby")

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

    # Verify content format (Type + Len + Path)
    # <<type::8, len::16-little, path_bin::binary-size(len), rest::binary>>

    # Helper to decode one entry
    decode_entry = fn binary ->
      case binary do
        <<type::8, len::16-little, name::binary-size(len), rest::binary>> ->
          {{type, name}, rest}

        _ ->
          :error
      end
    end

    # Decode first entry
    {{type, name}, rest} = decode_entry.(decoded)
    # File, Dir, Symlink
    assert type in [1, 2, 3]
    # Should be one of our files
    assert String.starts_with?(name, "f")

    # 5. Expect Done
    assert_push "filetree:done", %{}
  end
end
