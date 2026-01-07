# Master Plan: System Core (Elixir & Platform)

## 🧠 Core Strategy: The Orchestrator
Elixir serves as the "Brain" of the Ether IDE, responsible for state management, agent coordination, and process supervision, while offloading high-compute tasks to the Native Engine (Zig).

---

## 🤖 Agent Framework (Jido)
We leverage the `Jido` framework for modular, action-oriented intelligence.

### 1. Agent Roles
| Agent | Responsibility | Key Tools |
| :--- | :--- | :--- |
| **Commander** | High-level planning & delegation. | Goal-state management. |
| **Refactor** | Safe code transformations. | `Sourceror` (AST manipulation). |
| **Git** | Automated version control. | `System.cmd("git")`, Auto-commits. |
| **Command** | Generic task execution. | `Task.async`, PTY (Planned). |

### 2. Implementation Status
- [x] Initial agent definitions in `lib/ether/agents/`.
- [ ] Transition to standard `Jido.Action` primitives.
- [ ] Integration of `Instructor` for structured LLM completions.

---

## 🐘 Persistent State (PostgreSQL)
PostgreSQL provides long-term memory and project context.

### 1. DB Capabilities
- **Project Metadata:** Store open files, cursor positions, and per-project configurations.
- **AI Memory:** Utilize `pgvector` for storing code embeddings to enable semantic search.

### 2. Roadmap
- [ ] **Re-Activation:** Fix startup/migration logic and re-enable `Ether.Repo`.
- [ ] **Graceful Degradation:** Ensure IDE remains functional for basic edits if DB is unreachable.
- [ ] **Context Buffering:** Buffer project changes before flushing to DB to minimize I/O.

---

## 🛠️ Infrastructure & Dev Experience (DX)
"Zero Friction" workflow for Windows-based development.

### 1. Current Tooling
- **`start_dev.bat`:** Sequential ignition (Port cleanup -> Deps check -> Backend ready -> UI launch).
- **`verify_setup.bat`:** Full-stack environment sanity check.
- **`check_env.bat`:** Version parity verification.

### 2. Roadmap
- [ ] **`install_deps.bat`:** One-click environment setup via Scoop/Winget.
- [ ] **CI Pipeline:** GitHub Actions for multi-platform (Windows/Linux) validation.
- [ ] **Auto-Updater:** Tauri-native update delivery.

---

## 🧪 Testing & Quality Strategy
A multi-layered pyramid ensuring "Unbreakable" status.

1. **Unit (Elixir):** `mix test` for agent logic and channel handlers.
2. **Integrity (Hybrid):** Verifying NIF/BEAM interaction (politeness, memory).
3. **Fuzzing:** `StreamData` for boundary protection on binary protocols.
4. **End-to-End:** Verification of setup scripts and environment integration.

---

## 🚧 System Roadmap
- [ ] **LSP Integration:** Full `ElixirLS` support via a dedicated LSP Agent.
- [ ] **PTY Support:** Real terminal integration for `CommandAgent`.
- [ ] **Global Search:** Connecting the Zig Searcher results to the DB/UI.

---

## 📡 Networking & Channels (Phoenix)
Phoenix 1.8+ provides the high-speed bridge between Elixir and the Svelte frontend.

### 1. Strategy
- **Channel-First:** Strictly using WebSockets for real-time data flow.
- **No HTML:** The backend serves only JSON and binary frames; no `.heex` templates.
- **Presence:** Utilizing `Phoenix.Presence` for multi-window/multi-session synchronization.

### 2. Roadmap
- [ ] **Code Intelligence API:** Expose LSP-backed endpoints for hover/definition lookups.
- [ ] **Presence Tracking:** Shared "Current File" and cursor position across instances.
- [ ] **LiveTelemetry:** Dashboard integration for real-time monitoring of NIF memory and CPU.

---

## 🦀 The Shell (Rust / Tauri)
The Rust layer serves as the native OS container for the IDE.

### 1. Strategy
- **Thin Shell:** Rust focuses on window management and OS integration, delegating logic to the BEAM or WebView.
- **Sidecar Management:** Tauri orchestrates the lifecycle of the Elixir backend.

### 2. Roadmap
- [ ] **Window Mastery:** Implement frameless mode, Windows 11 Acrylic/Mica effects, and custom drag regions.
- [ ] **Native Integration:** Restore system menus (File/Edit), implement single-instance locks, and handle OS file associations (`.ex`, `.zig`).
- [ ] **Advanced Protocols:** Register a custom `ether://` protocol for deep linking.

---

*Last Updated: 2026-01-07*
