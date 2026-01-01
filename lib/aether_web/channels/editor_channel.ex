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
end
