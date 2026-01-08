IO.puts("\n🔍 Scanning Performance Benchmark (Agent-Driven)")
IO.puts("=" |> String.duplicate(50))

if Code.ensure_loaded?(Ether.Benchmark) do
  Ether.Benchmark.run_sync()
else
  IO.puts("❌ Ether.Benchmark not loaded. Run within mix context.")
end
