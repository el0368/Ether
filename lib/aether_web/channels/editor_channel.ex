defmodule AetherWeb.EditorChannel do
  use AetherWeb, :channel
  require Logger

  @impl true
  def join("editor:lobby", _payload, socket) do
    Logger.info("Client joined editor:lobby")
    # Trigger benchmark on startup
    # Trigger benchmark on startup
    # DISABLED: Too heavy for startup, causes white screen congestion
    # Aether.Benchmark.run()
    # Subscribe to file delta events
    Phoenix.PubSub.subscribe(Aether.PubSub, "filetree:deltas")
    # Start watching current directory
    # DIAGNOSIS: Disable Watcher to see if it causes 33s flood
    # Aether.Watcher.watch(".")
    {:ok, %{status: "connected"}, socket}
  end


  # Handle file delta broadcasts from Watcher
  @impl true
  def handle_info({:file_delta, %{path: path, type: type}}, socket) do
    push(socket, "filetree:delta", %{path: path, type: Atom.to_string(type)})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:binary, binary}, socket) when is_binary(binary) do
    # Pass-through: Base64 encode for transport efficiency (vs JSON list)
    # Ideally use raw binary frames, but Base64 is fine for now.
    encoded = Base.encode64(binary)
    push(socket, "filetree:chunk", %{chunk: encoded})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:scan_completed, _status}, socket) do
    Logger.info("CH: Scan Completed in #{System.monotonic_time(:millisecond) - socket.assigns[:scan_start]}ms")
    push(socket, "filetree:done", %{})
    {:noreply, socket}
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
  def handle_in("filetree:list_raw", %{"path" => path}, socket) do
    # Direct async stream from NIF to this Channel Process
    # NIF returns :ok immediately, then sends {:binary, bin} messages.
    logger_path = Path.expand(path)
    Logger.info("CH: Requested Raw Scan for: #{logger_path}")
    start_time = System.monotonic_time(:millisecond)
    
    case Aether.Scanner.scan_raw(path) do
      :ok ->
        {:reply, {:ok, %{status: "streaming"}}, assign(socket, :scan_start, start_time)}
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
  def handle_in("editor:recent", _payload, socket) do
    case Aether.Agents.FileServerAgent.get_recent_files() do
      {:ok, files} ->
        {:reply, {:ok, %{files: files}}, socket}
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
  # Phase 6: LSP

  @impl true
  def handle_in("lsp:did_open", %{"path" => path, "text" => text}, socket) do
    Aether.Agents.LSPAgent.did_open(path, text)
    {:noreply, socket}
  end

  @impl true
  def handle_in("lsp:did_change", %{"path" => path, "text" => text}, socket) do
    Aether.Agents.LSPAgent.did_change(path, text)
    {:noreply, socket}
  end

  @impl true
  def handle_in("lsp:completion", %{"path" => path, "line" => line, "column" => col}, socket) do
    case Aether.Agents.LSPAgent.completion(path, line, col) do
      {:ok, items} -> {:reply, {:ok, %{items: items}}, socket}
      {:error, reason} -> {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  @impl true
  def handle_in("search:global", %{"query" => query}, socket) do
    case Aether.Agents.FileServerAgent.search(query) do
      {:ok, results} -> {:reply, {:ok, %{results: results}}, socket}
      {:error, reason} -> {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  @impl true
  def handle_in("lsp:symbols", %{"path" => path}, socket) do
    case Aether.Agents.LSPAgent.document_symbols(path) do
      {:ok, symbols} -> {:reply, {:ok, %{symbols: symbols}}, socket}
      {:error, reason} -> {:reply, {:error, %{reason: inspect(reason)}}, socket}
    end
  end

  # Window Management
  # NOTE: Window controls are now handled by Tauri (Rust).
  # Legacy Desktop.Window handlers removed.
end

