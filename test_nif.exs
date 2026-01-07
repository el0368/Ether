IO.puts("Testing scan...")
case Ether.Scanner.scan(".") do
  results when is_list(results) -> 
    IO.puts("SUCCESS: Scanned #{length(results)} items")
    # Print first few items
    results |> Enum.take(5) |> Enum.each(&IO.inspect/1)
  error -> 
    IO.puts("FAILURE: #{inspect(error)}")
end
