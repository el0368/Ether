defmodule Ether.Native.StreamingTest do
  use ExUnit.Case
  @tag :native
  test "receives streamed chunks and completion signal" do
    # 1. Create a dummy directory with enough files to trigger chunking
    tmp_dir = System.tmp_dir!() |> Path.join("streaming_test_#{System.unique_integer()}")
    File.mkdir_p!(tmp_dir)
    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    # Create 1500 files (CHUNK_SIZE is 1000)
    for i <- 1..1500 do
      File.write!(Path.join(tmp_dir, "file_#{i}.txt"), "content")
    end

    # 2. Start Scan
    assert :ok = Ether.Native.Scanner.scan_raw(tmp_dir)
...

    # 3. Receive Messages
    # Expect at least 2 binary chunks (1000 + 500)
    
    receive do
      {:binary, bin1} when is_binary(bin1) -> 
        assert byte_size(bin1) > 0
        IO.puts("Received Chunk 1: #{byte_size(bin1)} bytes")
    after 1000 -> flunk("Timeout waiting for Chunk 1")
    end

    receive do
      {:binary, bin2} when is_binary(bin2) -> 
        assert byte_size(bin2) > 0
        IO.puts("Received Chunk 2: #{byte_size(bin2)} bytes")
    after 1000 -> flunk("Timeout waiting for Chunk 2")
    end

    # 4. Expect Completion
    receive do
      {:scan_completed, :ok} -> 
        IO.puts("Scan Completed Signal Received")
    after 1000 -> flunk("Timeout waiting for Completion Signal")
    end
  end
end
