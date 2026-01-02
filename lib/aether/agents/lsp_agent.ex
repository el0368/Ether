defmodule Aether.Agents.LSPAgent do
  @moduledoc """
  Language Server Protocol Agent.
  Acts as the central intelligence server for the editor, providing
  diagnostics, completion, and definition lookup.
  """
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    Logger.info("LSPAgent: Initializing...")
    {:ok, %{documents: %{}}}
  end

  # Public API

  def did_open(path, text) do
    GenServer.cast(__MODULE__, {:did_open, path, text})
  end

  def did_change(path, text) do
    GenServer.cast(__MODULE__, {:did_change, path, text})
  end

  def completion(path, line, column) do
    GenServer.call(__MODULE__, {:completion, path, line, column}, 30_000)
  end

  def document_symbols(path) do
    GenServer.call(__MODULE__, {:document_symbols, path}, 10_000)
  end

  # Callbacks

  def handle_cast({:did_open, path, text}, state) do
    Logger.debug("LSP: Opened #{path}")
    new_docs = Map.put(state.documents, path, text)
    {:noreply, %{state | documents: new_docs}}
  end

  def handle_cast({:did_change, path, text}, state) do
    new_docs = Map.put(state.documents, path, text)
    
    # Run diagnostics
    diagnostics = diagnose(text)
    
    # Broadcast diagnostics to all editors
    AetherWeb.Endpoint.broadcast("editor:lobby", "lsp:diagnostics", %{path: path, diagnostics: diagnostics})

    {:noreply, %{state | documents: new_docs}}
  end

  defp diagnose(text) do
    case Code.string_to_quoted(text) do
      {:ok, _ast} -> []
      {:error, {meta, message, _token}} ->
        line = meta[:line] || 1
        [
          %{
            from: %{line: line, col: 1},
            to: %{line: line, col: 1000},
            severity: :error,
            message: message
          }
        ]
    end
  end

  def handle_call({:completion, path, line, column}, _from, state) do
    text = Map.get(state.documents, path)
    
    # Call ElixirSense to get real suggestions (or mock in test)
    suggestions =
      if text do
        if Mix.env() == :test do
          # Mock response for tests to avoid heavy indexing
          [%{label: "defmodule", kind: :keyword, detail: "Kernel", documentation: "Defines a module"}]
        else
          results = ElixirSense.suggestions(text, line, column)
          
          Enum.map(results, fn item ->
            %{
              label: item[:label] || item[:name],
              kind: item[:type], 
              detail: item[:detail] || item[:summary],
              documentation: item[:doc]
            }
          end)
        end
      else
        []
      end

    {:reply, {:ok, suggestions}, state}
  end

  def handle_call({:document_symbols, path}, _from, state) do
    text = Map.get(state.documents, path)
    
    symbols =
      if text do
        extract_symbols(text)
      else
        []
      end
    
    {:reply, {:ok, symbols}, state}
  end

  defp extract_symbols(text) do
    case Code.string_to_quoted(text) do
      {:ok, ast} ->
        extract_from_ast(ast, [])
      {:error, _} ->
        []
    end
  end

  defp extract_from_ast({:defmodule, meta, [{:__aliases__, _, parts}, _]}, acc) do
    name = Enum.join(parts, ".")
    [%{name: "module #{name}", kind: :module, line: meta[:line] || 1} | acc]
  end

  defp extract_from_ast({kind, meta, [{name, _, _args} | _]}, acc) when kind in [:def, :defp] do
    label = if kind == :defp, do: "(private) #{name}", else: "#{name}"
    [%{name: label, kind: :function, line: meta[:line] || 1} | acc]
  end

  defp extract_from_ast({_, _, children}, acc) when is_list(children) do
    Enum.reduce(children, acc, &extract_from_ast/2)
  end

  defp extract_from_ast(_, acc), do: acc

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end
end
