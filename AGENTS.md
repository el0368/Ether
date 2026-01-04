# Aether IDE - Agent Architecture
**Last Updated:** 2026-01-04

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
**Responsibility:** High-performance directory traversal using a safe Zig NIF.

```elixir
# API
Aether.Scanner.scan(directory)  # Delegates to Native NIF (No Fallback)
```

### 3. ShellAgent
**Module:** `Aether.Agents.ShellAgent`
**Responsibility:** Execute system commands via Elixir Ports

```elixir
# API
ShellAgent.run(command)  # Broadcasts output via PubSub
```

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

---

## Quick Start (New PC Setup)

```bash
# After cloning on any PC:
.\check_env.bat      # Check tools installed
mix deps.get         # Install backend deps
cd assets && bun install && cd ..  # Frontend deps
.\verify_setup.bat   # TEST EVERYTHING
.\start_dev.bat      # Run if all tests pass
```