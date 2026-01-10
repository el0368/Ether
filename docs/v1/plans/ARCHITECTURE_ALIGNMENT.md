# Professional Blueprint: VS Code Parity Architecture (PLEX-Z)

This plan aligns the **Ether** project with the core architectural principles of VS Code, mapping them to the high-performance BEAM (Elixir/Erlang) and Native Zig layers.

## 1. Architectural Mapping

| VS Code Core | Ether (PLEX-Z) | Role |
| :--- | :--- | :--- |
| **Main Process** | **Tauri (Rust)** | Window management, Native Menu, OS lifecycle. |
| **Renderer** | **LiveView + JS Hooks** | UI rendering and micro-interactions (0ms). |
| **Extension Host** | **BEAM GenServers** | Isolated processes for logic (Git, LSP, Terminal). |
| **Shared Process** | **Elixir/Ets Agent Bank** | Synchronized state across restarts and windows. |
| **Native Spawners** | **Zig NIFs** | High-performance CPU tasks (Files, Grep, Diffing). |

---

## 2. Phase 1: High-Volume UI (Virtualization)
**Objective**: Handle 1,000,000 files with the same smoothness as VS Code.

- [ ] **Virtualized Explorer**: implement a JS Hook that only renders visible items in the file tree.
- [ ] **Optimistic Tree Toggles**: Folders rotate and "fake" expand/collapse instantly in JS before the server responds.

## 3. Phase 2: State Sovereignty (Service Layer)
**Objective**: Decouple the UI from the Scanner.

- [ ] **ProjectAgent**: A dedicated GenServer that maintains the file tree in memory (Ets) for the entire project.
- [ ] **Delta Bus**: Instead of re-scanning, the Agent listens for OS file events (via Zig) and broadcasts tiny "Deltas."

## 4. Phase 3: Language Intelligence (LSP Bridge)
**Objective**: Provide "Pro" features like Go-to-Definition and Linting.

- [ ] **LSP Manager**: An Elixir supervisor that manages Language Server binaries (e.g., `elixir-ls`, `zls`, `gopls`).
- [ ] **Monaco Bridge**: Connect Monaco Editor directly to the Elixir LSP Manager via WebSockets.

## 5. Phase 4: Native Power (Zig Upgrades)
**Objective**: Move all "Blocking" I/O to native code.

- [ ] **Zig Search**: Implement a high-speed `grep` equivalent in Zig.
- [ ] **Zig Watcher**: Implement native Windows `ReadDirectoryChangesW` in Zig to feed the Elixir ProjectAgent.

---

## Verification Plan

### Performance Benchmarks
- **File Load**: Explorer must handle a `node_modules` folder without frame drops.
- **Latency**: Activity bar switch must remain 0ms (Optimistic).
- **RAM**: Memory usage should stay flat during massive file scans.
