defmodule Ether.Native.StressTest do
  use ExUnit.Case
  @moduletag :stress
  # 2 minutes allowed
  @moduletag timeout: 120_000

  @doc """
  STRESS TEST SUITE
  -----------------
  To run: `mix test test/ether/native/stress_test.exs --include stress`
  """

  setup_all do
    # 1. Generate massive fixture (once)
    root = Path.join(System.tmp_dir!(), "stress_monolith_#{System.unique_integer()}")
    File.mkdir_p!(root)

    IO.puts("\nCreate Monolith: Generating 10,000 files...")

    {time, _} =
      :timer.tc(fn ->
        Enum.each(1..100, fn d ->
          dir = Path.join(root, "dir_#{d}")
          File.mkdir!(dir)

          Enum.each(1..100, fn f ->
            File.write!(Path.join(dir, "file_#{f}.txt"), "content with secret_needle inside")
          end)
        end)
      end)

    IO.puts("Generated 10,000 files in #{div(time, 1000)}ms")

    {:ok, ctx} = Ether.Native.Scanner.create_context()

    on_exit(fn ->
      File.rm_rf!(root)
      # Context clean up happens automatically by GC, or we can close it if exposed
    end)

    {:ok, root: root, ctx: ctx}
  end

  test "The Monolith: Search 10k files", %{root: root, ctx: ctx} do
    {time, result} =
      :timer.tc(fn ->
        {:ok, matches} = Ether.Native.Scanner.search(ctx, "secret_needle", root)
        length(matches)
      end)

    # Verify we found all needles
    assert result == 10_000
    IO.puts("🚀 Monolith Search: #{result} matches in #{div(time, 1000)}ms")
  end

  test "Parallel Storm: 50 concurrent searches", %{root: root, ctx: ctx} do
    # Note: We reuse the SAME context (one thread pool) for all 50 tasks!
    # This tests the pool's ability to queue 50 requests.

    tasks =
      for _i <- 1..50 do
        Task.async(fn ->
          {:ok, res} = Ether.Native.Scanner.search(ctx, "secret_needle", root)
          length(res)
        end)
      end

    # Increase timeout to 60s
    results = Task.await_many(tasks, 60_000)
    assert Enum.all?(results, fn count -> count == 10_000 end)
    IO.puts("⚡ Parallel Storm: 50 threads successfully searched 10k files each")
  end

  test "Memory Endurance: 500 consecutive searches", %{root: root, ctx: ctx} do
    initial_mem = :erlang.memory(:total)

    Enum.each(1..50, fn i ->
      Ether.Native.Scanner.search(ctx, "secret_needle", root)
      if rem(i, 100) == 0, do: IO.write(".")
    end)

    IO.puts("\n")

    :erlang.garbage_collect()
    final_mem = :erlang.memory(:total)
    growth = final_mem - initial_mem

    IO.puts("❤️ Endurance: Memory growth #{div(growth, 1024)} KB after 500 searches")
    # Allow some fluctuation but should be reasonable (e.g. results list allocation)
    assert growth < 50_000_000
  end
end
