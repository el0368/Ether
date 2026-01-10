defmodule Ether.ScannerTest do
  use ExUnit.Case
  alias Ether.Scanner

  test "scans current directory" do
    # This calls the Zig NIF
    files = Scanner.scan(".")

    assert is_list(files)
    assert files != []

    # Check if mix.exs exists in the list (since we are in project root)
    mix_file = Enum.find(files, fn {f, _type} -> String.ends_with?(f, "mix.exs") end)
    assert mix_file
  end

  test "scan returns absolute paths" do
    [{path, _type} | _] = Scanner.scan(".")
    assert Path.type(path) == :absolute
  end

  describe "Parallel Scan" do
    @tag :tmp_dir
    test "scans directory with many subdirs (triggers parallel logic)", %{tmp_dir: tmp_dir} do
      # Create 60 subdirectories to trigger PARALLEL_THRESHOLD (50)
      for i <- 1..60 do
        File.mkdir!(Path.join(tmp_dir, "sub_#{i}"))
        File.write!(Path.join([tmp_dir, "sub_#{i}", "file.txt"]), "content")
      end

      # Scan
      files = Ether.Scanner.scan(tmp_dir)

      # Verify: 60 subdirs + 60 files = 120 entries
      # Note: logic depends on if main dir is included, usually scan returns children.
      assert length(files) == 120
    end
  end
end
