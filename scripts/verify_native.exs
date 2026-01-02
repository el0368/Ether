try do
  IO.puts "🔍 Verifying Native Scanner..."
  path = "."
  case Aether.Native.Scanner.scan(path) do
    {:ok, files} -> 
      IO.puts "✅ NATIVE SCAN SUCCESS!"
      IO.inspect(files, label: "Files")
    {:error, reason} ->
      IO.puts "❌ Native Scan Failed: #{inspect(reason)}"
  end
rescue
  e -> IO.puts "🔥 CRASH: #{inspect(e)}"
end
