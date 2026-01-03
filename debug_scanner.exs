IO.puts "Debugging Scanner..."
case Aether.Scanner.scan_raw(".") do
  {:ok, bin} when is_binary(bin) ->
    IO.puts "Scan Success! Binary size: #{byte_size(bin)}"
    if byte_size(bin) > 0 do
       <<type::8, len::16-little, rest::binary>> = bin
       IO.puts "First byte: #{type}, First Len: #{len}"
    else
       IO.puts "Binary EMPTY!"
    end
  other ->
    IO.inspect(other, label: "Scan Result")
end
