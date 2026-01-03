{:ok, bin} = Aether.Scanner.scan_raw(".")
IO.puts "Binary size: #{byte_size(bin)}"
try do
  output = Jason.encode!(%{binary: bin})
  IO.puts "JSON Encode Success: #{String.slice(output, 0, 50)}..."
rescue
  e -> IO.puts "JSON Encode FAILED: #{inspect(e)}"
end
