IO.puts("Checking for Ether.Native.NifDecoder...")
if Code.ensure_loaded?(Ether.Native.NifDecoder) do
  IO.puts("YES: Ether.Native.NifDecoder is loaded")
else
  IO.puts("NO: Ether.Native.NifDecoder is NOT loaded")
end
