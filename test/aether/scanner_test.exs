defmodule Aether.ScannerTest do
  use ExUnit.Case
  alias Aether.Scanner

  test "scans current directory" do
    # This calls the Zig NIF
    files = Scanner.scan(".")
    
    assert is_list(files)
    assert files != []
    
    # Check if mix.exs exists in the list (since we are in project root)
    mix_file = Enum.find(files, fn f -> String.ends_with?(f, "mix.exs") end)
    assert mix_file
  end

  test "scan returns absolute paths" do
    [first_file | _] = Scanner.scan(".")
    assert Path.type(first_file) == :absolute
  end
end
