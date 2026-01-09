# Master Plan: System Core (Elixir & Platform)

## 🧠 Core Strategy: The Orchestrator
Elixir serves as the "Brain" of the Ether IDE, responsible for state management, agent coordination, and process supervision, while offloading high-compute tasks to the Native Engine (Zig).

---

## 🤖 Agent Framework (Jido)
We leverage the `Jido` framework for modular, action-oriented intelligence.

### 1. Agent Roles
| Agent | Responsibility | Key Tools | Status |
| :--- | :--- | :--- | :--- |
| **Commander** | High-level planning & delegation. | Goal-state management. | [ ] |
| **Refactor** | Safe code transformations. | `Sourceror` (AST manipulation). | [/] |
| **Git** | Automated version control. | `System.cmd("git")`, Auto-commits. | [/] |
| **Command** | Generic task execution. | `Task.async`, PTY (Planned). | [x] |

### 2. Implementation Status
- [x] Initial agent definitions in `lib/ether/agents/`.
- [ ] **Jido.Action**: Transition to standard `Jido.Action` primitives.
- [ ] **Instructor**: Integration of `Instructor` for structured LLM completions.

---

## 🐘 Persistent State (PostgreSQL)
PostgreSQL provides long-term memory and project context.

### 1. DB Capabilities
- [x] **Project Metadata:** Store open files, cursor positions, and per-project configurations.
- [ ] **AI Memory:** Utilize `pgvector` for storing code embeddings to enable semantic search.

### 2. Roadmap
- [ ] **Re-Activation:** Fix startup/migration logic and re-enable `Ether.Repo`.
- [ ] **Graceful Degradation:** Ensure IDE remains functional for basic edits if DB is unreachable.
- [ ] **Context Buffering:** Buffer project changes before flushing to DB to minimize I/O.

---

## 🛠️ Infrastructure & Dev Experience (DX)
"Zero Friction" workflow for Windows-based development.

### 1. Current Tooling
- [x] **`start_dev.bat`:** Sequential ignition (Port cleanup -> Deps check -> Backend ready -> UI launch).
- [x] **`verify_setup.bat`:** Full-stack environment sanity check.
- [x] **`check_env.bat`:** Version parity verification.

### 2. Roadmap
- [ ] **`install_deps.bat`:** One-click environment setup via Scoop/Winget.
- [ ] **CI Pipeline:** GitHub Actions for multi-platform (Windows/Linux) validation.
- [x] **Auto-Updater:** Tauri-native update delivery.

---

## 🧪 Testing & Quality Strategy
A multi-layered pyramid ensuring "Unbreakable" status.

1. [x] **Unit (Elixir):** `mix test` for agent logic and channel handlers.
2. [x] **Integrity (Hybrid):** Verifying NIF/BEAM interaction (politeness, memory).
3. [ ] **Fuzzing:** `StreamData` for boundary protection on binary protocols.
4. [x] **End-to-End:** Verification of setup scripts and environment integration.

---

## 💾 Data Strategy (PostgreSQL + Vector)
The database in Ether is **not** for storing your files (those live on the disk). It is for **Code Intelligence**.

### 1. Feature Set
- [ ] **Vector Search (`pgvector`):** Stores AI-generated embeddings of your code.
- [ ] **Symbol Index:** Caching Go-to-Definition and Find-All-References data.
- [x] **Workspace State:** Persisting your tabs, search history, and window layouts.

---

## ☁️ The Cloud-Hybrid Vision
Ether is designed to be **Platform Agnostic**. The SPEL-AI stack allows it to run as a native Tauri app or a web-based Cloud IDE.

### 1. Strategy
- [x] **Shared Backend:** The Elixir/Phoenix backend runs locally on your machine for Desktop, and in a container (Docker/Fly.io) for the Cloud.
- [x] **Zig in the Cloud:** Our high-performance Native Engine runs on the server.
- [x] **LiveView Everywhere:** The frontend logic remains 100% identical.

---

## 🤖 The Internal Architect (AI Self-Maintenance)
The ultimate goal of Ether is to be **Self-Healing**. 

### 1. The Maintenance Loop
- [ ] **Continuous Quality Agent:** An internal GenServer that constantly runs checks.
- [ ] **Gemini Integration:** Automated analysis of build errors.
- [ ] **Dependency Sentinel:** Automatically detects and verifies updates.

### 2. The Self-Updater
- [x] **Tauri Native Updater:** Using Tauri's signature-based update system.
- [ ] **Git-Native Evolution:** AI-suggested refactors with user approval.

---

## 🚧 System Roadmap
- [ ] **LSP Integration:** Full `ElixirLS` support via a dedicated LSP Agent.
- [ ] **PTY Support:** Real terminal integration for `CommandAgent`.
- [ ] **Global Search:** Connecting the Zig Searcher results to the DB/UI.
- [ ] **Agent Registry:** A central hub for managing localized AI agents.
- [ ] **Recursive CI:** The IDE runs its own CI pipeline internally.
- [ ] **Web-Shell Auth:** Standardized session management for the Cloud version.

---

## 📡 LiveView & Channels (Phoenix)
Phoenix 1.8+ provides the high-speed backbone for the Ether IDE.

### 1. Strategy
- [x] **LiveView-First:** Unified state management.
- [x] **HEEx Templates:** leveraging server-side rendering for complex layouts.
- [x] **JS Hooks:** Surgical interop for heavy components.
- [x] **Streams:** Efficient data patching.
- [ ] **Presence:** Utilizing `Phoenix.Presence` for multi-window sync.

### 2. Roadmap
- [ ] **Code Intelligence API:** Expose LSP-backed endpoints for hover/definition lookups.
- [ ] **Presence Tracking:** Shared "Current File" across instances.
- [ ] **LiveTelemetry:** Dashboard integration for NIF monitoring.

---

## 🦀 The Shell (Rust / Tauri)
The Rust layer serves as the native OS container for the IDE.

### 1. Strategy
- [x] **Thin Shell:** Rust focuses on window management.
- [x] **Sidecar Management:** Tauri orchestrates the Elixir backend.

### 2. Roadmap
- [ ] **Window Mastery:** Implement frameless mode, Acrylic/Mica effects.
- [ ] **Native Integration:** Restore system menus (File/Edit), OS file associations.
- [ ] **Advanced Protocols:** Register custom `ether://` protocol.

---

*Last Updated: 2026-01-09 (Post-LiveView Migration)*
