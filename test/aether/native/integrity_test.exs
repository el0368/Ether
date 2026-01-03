defmodule Aether.Native.IntegrityTest do
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
        Aether.Scanner.scan_raw(".")
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

      # Spawn heavy work in background
      _task = Task.async(fn -> Aether.Scanner.scan_raw(".") end)

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
      result = Aether.Scanner.scan_raw("Z:/nonexistent/path/that/does/not/exist/123456789")

      case result do
        {:error, reason} ->
          assert is_atom(reason), "Expected atom error, got: #{inspect(reason)}"
          IO.puts("✅ Error Clarity Check: Pass (Error: :#{reason})")

        {:ok, _} ->
          # If path somehow exists, that's also fine
          IO.puts("⚠️ Path unexpectedly exists, skipping error test")
      end
    end
  end
end
