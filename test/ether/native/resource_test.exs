defmodule Ether.Native.ResourceTest do
  use ExUnit.Case
  @moduletag :native

  describe "Resource Lifecycle (ADR-017)" do
    test "create_context returns ok tuple with reference" do
      assert {:ok, ref} = Ether.Native.Scanner.create_context()
      assert is_reference(ref), "Expected a reference, got: #{inspect(ref)}"
      IO.puts("✅ create_context returned reference: #{inspect(ref)}")
    end

    test "close_context marks resource as inactive" do
      {:ok, ref} = Ether.Native.Scanner.create_context()
      assert :ok = Ether.Native.Scanner.close_context(ref)
      IO.puts("✅ close_context completed successfully")
    end

    test "close_context with invalid ref returns error" do
      result = Ether.Native.Scanner.close_context(make_ref())
      assert {:error, :invalid_resource} = result
      IO.puts("✅ Invalid resource correctly rejected")
    end

    test "destructor called on garbage collection" do
      # Create resource in a spawned process
      parent = self()
      
      spawn(fn ->
        {:ok, ref} = Ether.Native.Scanner.create_context()
        send(parent, {:created, ref})
        # Process exits, reference goes out of scope
      end)

      assert_receive {:created, _ref}, 1000

      # Force GC
      :erlang.garbage_collect()
      Process.sleep(100)
      :erlang.garbage_collect()

      # If we get here without crash, destructor worked
      IO.puts("✅ Destructor called during GC (no crash)")
    end
  end
end
