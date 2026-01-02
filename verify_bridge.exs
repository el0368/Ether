require Logger
Logger.configure(level: :debug)

IO.puts("--- Bridge Verification Start ---")
case Aether.Native.Bridge.scan(".") do
  {:ok, files} ->
    IO.puts("Bridge returned #{length(files)} files.")
    IO.puts("Bridge Status: VERIFIED")
  error ->
    IO.puts("Bridge Failed: #{inspect(error)}")
    System.halt(1)
end
IO.puts("--- Verification Complete ---")
