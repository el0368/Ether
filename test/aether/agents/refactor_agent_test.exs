defmodule Aether.Agents.RefactorAgentTest do
  use ExUnit.Case, async: true
  alias Aether.Agents.RefactorAgent

  test "renames variable in simple expression" do
    code = """
    def hello do
      name = "World"
      IO.puts("Hello " <> name)
    end
    """

    {:ok, new_code} = RefactorAgent.rename_variable(code, "name", "recipient")
    
    assert new_code =~ "recipient = \"World\""
    assert new_code =~ "IO.puts(\"Hello \" <> recipient)"
  end
  
  test "handles complex nesting" do
    code = """
    def complex do
      x = 1
      if true do
        x = x + 1
      end
      x
    end
    """
    
    {:ok, new_code} = RefactorAgent.rename_variable(code, "x", "count")
    
    assert new_code =~ "count = 1"
    assert new_code =~ "count = count + 1"
    # Ensure the last line is just the variable name
    assert String.ends_with?(String.trim(new_code), "count\nend") or String.ends_with?(String.trim(new_code), "count")
  end
end
