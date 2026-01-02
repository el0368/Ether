defmodule AetherWeb.EditorChannel do
  use AetherWeb, :channel
  require Logger

  @impl true
  def join("editor:lobby", _payload, socket) do
    Logger.info("Client joined editor:lobby")
    {:ok, %{status: "connected"}, socket}
  end

  # File Operations

  @impl true
  def handle_in("filetree:list", %{"path" => path}, socket) do
    case Aether.Agents.FileServerAgent.list_files(path) do
      {:ok, files} ->
        {:reply, {:ok, %{files: files}}, socket}
      {:error, reason} ->
        {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  @impl true
  def handle_in("editor:read", %{"path" => path}, socket) do
    case Aether.Agents.FileServerAgent.read_file(path) do
      {:ok, content} ->
        {:reply, {:ok, %{content: content}}, socket}
      {:error, reason} ->
        {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  @impl true
  def handle_in("editor:save", %{"path" => path, "content" => content}, socket) do
    case Aether.Agents.FileServerAgent.write_file(path, content) do
      :ok ->
        {:reply, {:ok, %{status: "saved"}}, socket}
      {:error, reason} ->
        {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  # Development Lifecycle - Testing

  @impl true
  def handle_in("test:run_all", _payload, socket) do
    case Aether.Agents.TestingAgent.run_all() do
      {:ok, result} ->
        {:reply, {:ok, result}, socket}
      {:error, result} ->
        {:reply, {:error, result}, socket}
    end
  end

  @impl true
  def handle_in("test:run_file", %{"path" => path}, socket) do
    case Aether.Agents.TestingAgent.run_file(path) do
      {:ok, result} ->
        {:reply, {:ok, result}, socket}
      {:error, result} ->
        {:reply, {:error, result}, socket}
    end
  end

  # Development Lifecycle - Linting

  @impl true
  def handle_in("lint:check_all", _payload, socket) do
    case Aether.Agents.LintAgent.check_all() do
      {:ok, result} ->
        {:reply, {:ok, result}, socket}
      {:error, result} ->
        {:reply, {:error, result}, socket}
    end
  end

  @impl true
  def handle_in("lint:check_file", %{"path" => path}, socket) do
    case Aether.Agents.LintAgent.check_file(path) do
      {:ok, result} ->
        {:reply, {:ok, result}, socket}
      {:error, result} ->
        {:reply, {:error, result}, socket}
    end
  end

  # Development Lifecycle - Formatting

  @impl true
  def handle_in("format:all", _payload, socket) do
    case Aether.Agents.FormatAgent.format_all() do
      {:ok, result} ->
        {:reply, {:ok, result}, socket}
      {:error, result} ->
        {:reply, {:error, result}, socket}
    end
  end

  @impl true
  def handle_in("format:file", %{"path" => path}, socket) do
    case Aether.Agents.FormatAgent.format_file(path) do
      {:ok, result} ->
        {:reply, {:ok, result}, socket}
      {:error, result} ->
        {:reply, {:error, result}, socket}
    end
  end

  @impl true
  def handle_in("format:check", _payload, socket) do
    case Aether.Agents.FormatAgent.check() do
      {:ok, result} ->
        {:reply, {:ok, result}, socket}
      {:error, result} ->
        {:reply, {:error, result}, socket}
    end
  end
  # Advanced Agents (Phase 4/5)

  @impl true
  def handle_in("refactor:rename", %{"code" => code, "old_name" => old, "new_name" => new}, socket) do
    case Aether.Agents.RefactorAgent.rename_variable(code, old, new) do
      {:ok, result} -> {:reply, {:ok, %{code: result}}, socket}
      {:error, reason} -> {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  @impl true
  def handle_in("git:status", _payload, socket) do
    case Aether.Agents.GitAgent.status() do
      {:ok, result} -> {:reply, {:ok, %{status: result}}, socket}
      {:error, reason} -> {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  @impl true
  def handle_in("git:add", %{"path" => path, "files" => files}, socket) do
    case Aether.Agents.GitAgent.add(path, files) do
      {:ok, result} -> {:reply, {:ok, %{output: result}}, socket}
      {:error, reason} -> {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  @impl true
  def handle_in("git:commit", %{"path" => path, "message" => msg}, socket) do
    case Aether.Agents.GitAgent.commit(path, msg) do
      {:ok, result} -> {:reply, {:ok, %{output: result}}, socket}
      {:error, reason} -> {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  @impl true
  def handle_in("cmd:exec", %{"cmd" => cmd, "args" => args}, socket) do
    case Aether.Agents.CommandAgent.exec(cmd, args) do
      {:ok, result} -> {:reply, {:ok, %{output: result}}, socket}
      {:error, reason} -> {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end
end
