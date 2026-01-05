# Script to verify Native Scanner NIF
IO.puts("== Verifying Native Scanner ==")

try do
  case Ether.Native.Scanner.scan("C:/") do
    {:ok, msg} -> 
      IO.puts("SUCCESS: NIF Loaded and Executed.")
      IO.puts("Returned: #{inspect(msg)}")
    {:error, reason} -> 
      IO.puts("FAILURE: NIF Returned Error: #{inspect(reason)}")
    other -> 
      IO.puts("FAILURE: Unexpected Return: #{inspect(other)}")
  end
rescue
  e -> IO.puts("CRASH: #{inspect(e)}")
end
