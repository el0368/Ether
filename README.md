# Ether IDE ⚡

**The AI-Native, Cross-Platform IDE built on the BEAM with Zig-powered Native Performance.**

Ether is an experimental IDE designed for professional efficiency, combining Elixir's fault-tolerant runtime with Zig's zero-overhead native code. It runs as a standalone desktop application (via Tauri) or in the browser, offering a modern development experience.

## 🏗️ Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Svelte 5 (Runes) + Tailwind CSS |
| **Backend** | Phoenix 1.8 + Elixir |
| **Native** | Zig NIFs (Level 6 Performance) |
| **Desktop** | Tauri v2 (Rust) |
| **Icons** | Lucide |

## ✨ Features

### Core IDE
- **Native File Scanner**: High-performance directory traversal via Zig NIFs
- **Parallel Content Search**: Multi-threaded grep implementation
- **Real-time Updates**: WebSocket-based file tree with incremental deltas
- **Virtual Scrolling**: Handles 100k+ files without UI lag

### Agentic Core
| Agent | Description |
|-------|-------------|
| `FileServerAgent` | Safe filesystem access with recent files tracking |
| `TestingAgent` | Automated test runner (`mix test`) |
| `LintAgent` | Code quality checker (`mix credo`) |
| `FormatAgent` | Auto-formatter (`mix format`) |
| `RefactorAgent` | AST-based code refactoring (Sourceror) |
| `GitAgent` | Version control operations |
| `LSPAgent` | Language Server Protocol support |

### Native Performance (Zig NIFs)
- **Level 5 Stability**: Zero-panic guarantees with yielding NIFs
- **Level 6 Speed**: Thread pool parallelism for search operations
- **BEAM Citizenship**: Cooperative scheduling via `enif_consume_timeslice`

## 🛠️ Getting Started

### Prerequisites
- Elixir 1.18+ & Erlang/OTP 27+
- Zig 0.14+
- Rust 1.75+ (for Tauri desktop shell)
- Bun 1.0+ (or Node.js 20+)
- Git

### Quick Start

```bash
# Clone the repository
git clone https://github.com/el0368/Ether.git
cd Ether

# Check environment
.\bat\check_env.bat

# Install dependencies
mix deps.get
cd assets && bun install && cd ..

# Verify setup
.\bat\verify_setup.bat

# Run in browser mode
.\bat\start_dev.bat

# OR run in desktop mode (Tauri)
.\bat\start_tauri.bat
```

### Development Modes

| Mode | Command | Description |
|------|---------|-------------|
| **Browser** | `.\bat\start_dev.bat` | Phoenix + Vite at `localhost:5173` |
| **Desktop** | `.\bat\start_tauri.bat` | Native Tauri window |
| **Backend Only** | `.\run_backend.bat` | API at `localhost:4000` |

## 🧠 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Tauri Shell (Rust)                   │
├─────────────────────────────────────────────────────────┤
│              Svelte 5 Frontend (WebView)                │
├─────────────────────────────────────────────────────────┤
│         Phoenix Channels (WebSocket Real-time)          │
├─────────────────────────────────────────────────────────┤
│              Elixir Agents (GenServer)                  │
├─────────────────────────────────────────────────────────┤
│              Zig NIFs (Native Performance)              │
└─────────────────────────────────────────────────────────┘
```

### Key Design Decisions
- **Hybrid Shim Architecture**: C entry point (`entry.c`) bridges Erlang NIF ABI to pure Zig logic
- **Resource Handles**: BEAM-managed lifecycle for thread pools and native state
- **Chunked Streaming**: Binary protocol for efficient data transfer to frontend

## 📁 Project Structure

```
Ether/
├── assets/           # Svelte 5 frontend
├── bat/              # Windows launch scripts
├── config/           # Elixir configuration
├── docs/             # Documentation & ADRs
├── lib/              # Elixir application
│   ├── ether/        # Core logic & agents
│   └── ether_web/    # Phoenix web layer
├── native/           # Zig NIFs
│   └── scanner/      # High-performance scanner
├── priv/             # Static assets & compiled NIFs
├── src-tauri/        # Tauri desktop shell
└── test/             # Test suites
```

## 📚 Documentation

- **[DEVLOG.md](docs/logs/DEVLOG.md)**: Development history
- **[WALKTHROUGH.md](docs/reference/WALKTHROUGH.md)**: Feature implementation details
- **[ADRs](docs/adr/)**: Architecture Decision Records

## 🧪 Testing

```bash
# Run all tests
mix test

# Run native integrity tests
mix test test/ether/native/

# Lint code
mix credo --strict

# Format code
mix format
```

---
*Built with ❤️ using Elixir, Zig, and Rust*
