defmodule Ether.Native.StreamingTest do
  use ExUnit.Case
  @moduletag :native

  # ============================================================================
  # Baseline Streaming Test (Level 5)
  # ============================================================================
  test "receives streamed chunks and completion signal" do
    tmp_dir = System.tmp_dir!() |> Path.join("streaming_test_#{System.unique_integer()}")
    File.mkdir_p!(tmp_dir)
    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    for i <- 1..1500 do
      File.write!(Path.join(tmp_dir, "file_#{i}.txt"), "content")
    end

    assert {:ok, _} = Ether.Native.Scanner.scan_raw(tmp_dir)

    receive do
      {:scanner_chunk, bin1} when is_binary(bin1) ->
        assert byte_size(bin1) > 0
        IO.puts("Received Chunk 1: #{byte_size(bin1)} bytes")
    after
      1000 -> flunk("Timeout waiting for Chunk 1")
    end

    receive do
      {:scanner_chunk, bin2} when is_binary(bin2) ->
        assert byte_size(bin2) > 0
        IO.puts("Received Chunk 2: #{byte_size(bin2)} bytes")
    after
      1000 -> flunk("Timeout waiting for Chunk 2")
    end

    receive do
      {:scanner_done, _} ->
        IO.puts("Scan Completed Signal Received")
    after
      1000 -> flunk("Timeout waiting for Completion Signal")
    end
  end

  # ============================================================================
  # Pre-flight Shield Tests (Level 6 Readiness)
  # ============================================================================

  @tag :unicode
  test "correctly handles Unicode and Emoji filenames" do
    tmp_dir = System.tmp_dir!() |> Path.join("unicode_test_#{System.unique_integer()}")
    File.mkdir_p!(tmp_dir)
    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    # Create files with complex Unicode names
    unicode_names = [
      "emoji_🚀_rocket.txt",
      "chinese_中文文件.txt",
      "japanese_日本語.txt",
      "korean_한국어.txt",
      "arabic_العربية.txt",
      "thai_ภาษาไทย.txt",
      "mixed_日本🎉中文.txt"
    ]

    for name <- unicode_names do
      File.write!(Path.join(tmp_dir, name), "content")
    end

    assert {:ok, _} = Ether.Native.Scanner.scan_raw(tmp_dir)

    # Drain all messages
    results = drain_messages([])

    # Verify we got data and completion
    assert Enum.any?(results, fn msg -> match?({:scanner_chunk, _}, msg) end),
           "Expected at least one scanner_chunk"

    assert Enum.any?(results, fn msg -> match?({:scanner_done, _}, msg) end),
           "Expected completion signal"

    IO.puts("Unicode test passed with #{length(unicode_names)} special filenames")
  end

  @tag :concurrency
  test "handles concurrent scans without race conditions" do
    # Create 3 separate test directories
    dirs =
      for i <- 1..3 do
        dir = System.tmp_dir!() |> Path.join("concurrent_test_#{i}_#{System.unique_integer()}")
        File.mkdir_p!(dir)

        for j <- 1..100 do
          File.write!(Path.join(dir, "file_#{j}.txt"), "content")
        end

        dir
      end

    on_exit(fn -> Enum.each(dirs, &File.rm_rf!/1) end)

    # Launch all scans concurrently
    tasks =
      Enum.map(dirs, fn dir ->
        Task.async(fn ->
          {:ok, _} = Ether.Native.Scanner.scan_raw(dir)
          drain_messages([])
        end)
      end)

    # Wait for all to complete
    results = Task.await_many(tasks, 10_000)

    # Each scan should have completed successfully
    for result <- results do
      assert Enum.any?(result, fn msg -> match?({:scanner_done, _}, msg) end),
             "Expected completion signal for each concurrent scan"
    end

    IO.puts("Concurrency test passed with #{length(dirs)} parallel scans")
  end

  # ============================================================================
  # Helpers
  # ============================================================================
  defp drain_messages(acc) do
    receive do
      msg -> drain_messages([msg | acc])
    after
      500 -> Enum.reverse(acc)
    end
  end
end
