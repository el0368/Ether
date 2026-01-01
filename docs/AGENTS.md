# Aether IDE - Agent Architecture
**Last Updated:** 2026-01-01

---

## Overview

Aether uses a multi-agent architecture where specialized agents handle different aspects of IDE functionality. All agents are Pure Elixir GenServers orchestrated via Phoenix Channels.

---

## Core Agents

### 1. FileServerAgent
**Module:** `Aether.Agents.FileServerAgent`
**Responsibility:** Safe file I/O operations

```elixir
# API
FileServerAgent.read_file(path)    # {:ok, content} | {:error, reason}
FileServerAgent.write_file(path, content)  # :ok | {:error, reason}
FileServerAgent.list_files(path)   # {:ok, [files]}
```

### 2. Scanner
**Module:** `Aether.Scanner`
**Responsibility:** Fast directory traversal using `Task.async_stream`

```elixir
# API
Aether.Scanner.scan(directory)  # [list of absolute paths]
```

### 3. ShellAgent
**Module:** `Aether.Agents.ShellAgent`
**Responsibility:** Execute system commands via Elixir Ports

```elixir
# API
ShellAgent.run(command)  # Broadcasts output via PubSub
```

---

## Future Agents (Planned)

### 4. CommanderAgent
**Responsibility:** Orchestrate multi-step AI workflows
- Uses `Jido` for action planning
- Uses `Instructor` for structured LLM outputs

### 5. IndexerAgent
**Responsibility:** Build and maintain code search index
- AST parsing for Elixir/JavaScript
- Semantic embeddings for search

### 6. DiagnosticsAgent
**Responsibility:** Run linters, formatters, type checkers
- `mix format --check-formatted`
- `mix credo`
- Language-specific LSP integration

---

## Communication Pattern

```
Frontend (Svelte)
    ↓ Phoenix Channel
EditorChannel
    ↓ GenServer.call
Agent (FileServer, Shell, etc.)
    ↓ PubSub broadcast
EditorChannel
    ↓ push
Frontend (Svelte)
```

All agents are supervised under `Aether.Application`.
