defmodule Ether.Native.SearchTest do
  use ExUnit.Case
  alias Ether.Native.Scanner

  @moduletag :native

  setup do
    # Create a temporary directory structure
    root = Path.join(System.tmp_dir!(), "search_test_#{System.unique_integer()}")
    File.mkdir_p!(Path.join(root, "subdir/nested"))

    # Create files
    File.write!(Path.join(root, "root_match.txt"), "Target found here")
    File.write!(Path.join(root, "root_miss.txt"), "Nothing to see")
    File.write!(Path.join(root, "subdir/sub_match.txt"), "Target found here too")
    File.write!(Path.join(root, "subdir/sub_miss.txt"), "Empty")
    File.write!(Path.join(root, "subdir/nested/deep_match.txt"), "Target deep down matches")

    on_exit(fn -> File.rm_rf(root) end)

    {:ok, ctx} = Scanner.create_context()
    {:ok, %{root: root, ctx: ctx}}
  end

  describe "Native Content Search (Level 6)" do
    test "finds matches recursively", %{root: root, ctx: ctx} do
      {:ok, results} = Scanner.search(ctx, "Target", root)

      # Should find 3 files
      assert length(results) == 3

      # Verify paths (normalize separators for Windows)
      result_str = Enum.join(results, "\n")
      assert result_str =~ "root_match.txt"
      assert result_str =~ "sub_match.txt"
      assert result_str =~ "deep_match.txt"
    end

    test "returns empty list for no matches", %{root: root, ctx: ctx} do
      {:ok, results} = Scanner.search(ctx, "NonExistentString123", root)
      assert results == []
    end
  end
end
