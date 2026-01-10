defmodule Ether.Agents.RefactorAgent do
  @moduledoc """
  The Architect of Ether.
  Responsible for safe, AST-based code modifications.
  """
  use Jido.Agent,
    name: "refactor_agent",
    description: "Safely refactors Elixir code using AST manipulation."

  require Logger

  @doc """
  Renames a variable in the provided code snippet.
  """
  def rename_variable(code, old_name, new_name) do
    Logger.debug("RefactorAgent: Renaming variable '#{old_name}' to '#{new_name}'")

    # Use Sourceror to parse and traverse the AST
    quoted = Sourceror.parse_string!(code)

    target_atom = String.to_atom(old_name)
    new_atom = String.to_atom(new_name)

    # Traverse and transform
    {new_quoted, _} =
      Macro.traverse(
        quoted,
        nil,
        fn
          # Match variable nodes
          {name, meta, context}, acc when name == target_atom and is_atom(context) ->
            {{new_atom, meta, context}, acc}

          # Pass through everything else
          other, acc ->
            {other, acc}
        end,
        fn node, acc -> {node, acc} end
      )

    # Convert back to source code
    {:ok, Sourceror.to_string(new_quoted)}
  rescue
    e ->
      Logger.error("RefactorAgent: Failed to rename variable - #{inspect(e)}")
      {:error, inspect(e)}
  end
end
