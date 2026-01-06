defmodule Ether.Native.DefensiveTest do
  use ExUnit.Case
  @moduletag :native

  describe "Defensive API (Phase 3-4)" do
    test "scan_raw rejects non-binary path" do
      # Pass an atom instead of binary string
      result = try do
        Ether.Native.Scanner.scan_nif(:not_a_string, self())
      rescue
        ArgumentError -> {:error, :badarg}
      end

      assert result in [{:error, :invalid_path_type}, {:error, :badarg}],
             "Expected error for non-binary path, got: #{inspect(result)}"
      IO.puts("✅ Non-binary path correctly rejected")
    end

    test "scan_raw rejects non-pid second argument" do
      result = try do
        Ether.Native.Scanner.scan_nif(".", :not_a_pid)
      rescue
        ArgumentError -> {:error, :badarg}
      end

      assert result in [{:error, :invalid_pid_type}, {:error, :badarg}],
             "Expected error for non-pid, got: #{inspect(result)}"
      IO.puts("✅ Non-pid correctly rejected")
    end
  end
end
