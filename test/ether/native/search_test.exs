defmodule Ether.Native.SearchTest do
  use ExUnit.Case
  alias Ether.Native.Scanner

  @moduletag :native

  setup do
    # Create a temporary file for testing
    path = Path.join(System.tmp_dir!(), "search_test_#{System.unique_integer()}.txt")
    File.write!(path, "Hello from the Native Scanner Level 6\nFound this needle yet?")
    on_exit(fn -> File.rm(path) end)

    {:ok, ctx} = Scanner.create_context()
    {:ok, %{path: path, ctx: ctx}}
  end

  describe "Native Content Search (Level 6)" do
    test "finds existing string", %{path: path, ctx: ctx} do
      assert Scanner.search(ctx, "Native Scanner", path) == :match
      assert Scanner.search(ctx, "needle", path) == :match
    end

    test "returns :no_match for missing string", %{path: path, ctx: ctx} do
      assert Scanner.search(ctx, "missing_value", path) == :no_match
    end

    test "handles case sensitivity (default sensitive)", %{path: path, ctx: ctx} do
      # perform_search uses std.mem.indexOf which is case-sensitive
      assert Scanner.search(ctx, "native scanner", path) == :no_match
    end
  end
end
