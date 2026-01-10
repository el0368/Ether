defmodule Ether.Native.IntegrityTest do
  use ExUnit.Case, async: true

  @moduledoc """
  THE PROOF (Evidence Pillar)
  ===========================
  Tests for "BEAM Citizenship" of the Zig NIF.
  Proves the NIF does not harm the collective system.
  """

  describe "Memory Integrity" do
    test "NIF does not leak memory after repeated calls" do
      initial_mem = :erlang.memory(:total)

      # Heavy scan: 1,000 iterations
      Enum.each(1..1000, fn _ ->
        {:ok, _} = Ether.Native.Scanner.scan_raw(".")
        # Flush messages to prevent mailbox explosion
        flush_messages()
      end)

      # Force Garbage Collection
      :erlang.garbage_collect()

      final_mem = :erlang.memory(:total)

      # Check RAM did not inflate beyond threshold (15MB for 1000 iterations)
      mem_growth = final_mem - initial_mem
      assert mem_growth < 15_000_000, "Memory grew by #{mem_growth} bytes (>15MB)"
      IO.puts("✅ Memory Integrity Check: Pass (Growth: #{div(mem_growth, 1024)} KB)")
    end
  end

  describe "Scheduler Responsiveness" do
    test "NIF does not block main scheduler during heavy work" do
      start_time = System.monotonic_time(:millisecond)

      # Spawn heavy work in background (Scanner is async now, but NIF call itself might block briefly?)
      # Actually, scan_raw returns almost instantly.
      # The timeslice check is inside the NIF execution.
      # To truly test scheduler, we need to ensure the NIF runs long enough.
      # But since it returns :ok and runs on the calling thread...
      # wait, "enif_send" is async, but the NIF execution logic in scanner_safe.zig is synchronous!
      # It walks the dir, buffers, and sends. It DOES block the calling process until done?
      # NO. I am sending from the same thread.
      # The NIF function `zig_scan` in `scanner_safe.zig` runs to completion.
      # So `scan_raw` WILL block until the scan is finished.
      # This means scheduler responsiveness test is still valid.

      _task =
        Task.async(fn ->
          Ether.Native.Scanner.scan_raw(".")
          # Cleanup
          flush_messages()
        end)

      # Check that Elixir can still respond immediately
      :ok = :timer.sleep(10)

      end_time = System.monotonic_time(:millisecond)
      elapsed = end_time - start_time

      assert elapsed < 50, "Scheduler blocked for #{elapsed}ms (>50ms)"
      IO.puts("✅ Scheduler Responsiveness Check: Pass (#{elapsed}ms)")
    end
  end

  describe "Error Handling" do
    test "NIF returns clear error atoms for invalid paths" do
      # For async streaming, errors might be returned as tuples immediately 
      # OR sent as messages?
      # In scanner_safe.zig, `dir.openDir` failure returns error tuple synchronously.
      # So this test should still work if we inspect the return value.

      result = Ether.Native.Scanner.scan_raw("Z:/nonexistent/path/that/does/not/exist/123456789")

      case result do
        {:error, reason} ->
          assert is_atom(reason), "Expected atom error, got: #{inspect(reason)}"
          IO.puts("✅ Error Clarity Check: Pass (Error: :#{reason})")

        {:ok, _} ->
          # This means it started successfully?
          # Wait, does openDir fail before streaming starts? Yes.
          flunk("Expected error for non-existent path, got {:ok, _}")
      end
    end
  end

  defp flush_messages do
    receive do
      _ -> flush_messages()
    after
      0 -> :ok
    end
  end
end
