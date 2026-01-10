# Professional Blueprint: VS Code Parity Architecture (PLEX-Z)

This plan aligns the **Ether** project with the core architectural principles of VS Code, mapping them to the high-performance BEAM (Elixir/Erlang) and Native Zig layers.

## 1. Professional Architecture Map

| Layer | Technology | Responsibility |
| :--- | :--- | :--- |
| **View (Renderer)** | **HTML / Tailwind / Monaco** | Text rendering, UI components, and micro-animations. |
| **Window Shell** | **Tauri (Rust)** | Native OS integration, File I/O, window management. |
| **Logic Engine** | **Zig** | High-speed text processing, Piecetable, Search, Indexing. |
| **Services (The Brain)** | **Elixir / Phoenix** | AI Agents, Collaboration, Context Server, DB (Postgres). |

---

## 2. Solo Developer Strategy

To master systems architecture as a solo dev, we prioritize **World-Class Toolkits** combined with focused **Glue Logic**.

### Phase 1: The Shell (Tauri & Rust)
- **UI Architecture**: Leverage **Monaco Editor** for industrial-grade text logic. Use **JS Hooks** for 0ms transitions.
- **Native Bridge**: Use Rust's `Managed State` to track open buffers and user configuration.
- **Reliability**: Use Rust for the stable native interface and OS interaction.

### Phase 2: The Heavy Lifter (Zig)
- **Piece Table Implementation**: Use Zig to build the core text-management data structure (managing fragments instead of giant strings).
- **Native Indexing**: Implement high-throughput `grep` and project-wide indexing in Zig.
- **FFI Integration**: Compile Zig to C-compatible libraries to be consumed by the Rust shell.

### Phase 3: The Brain (Elixir & Phoenix)
- **Agentic Context**: Use Elixir to manage a background "context server" with `pgvector` for AI-assisted coding.
- **Real-time Sync**: Leverage Phoenix Channels for multi-user collaboration or multi-device sync.
- **Administrative UI**: Use Phoenix LiveView for complex internal state (Settings, Extension Marketplace).

---

## 3. Solo Dev Planning Checklist

- [ ] **Piece Table Research**: Understand how top-tier editors store text (fragments vs. buffers). Implement in **Zig**.
- [ ] **LSP Client Protocol**: Build a robust LSP client in **Rust** to support all languages (Python, Go, etc.) out-of-the-box.
- [ ] **Niche Identity**: Define the "Ether Difference." (e.g., Mathematical Authoring, Agentic-First, etc.)

---

## 4. Execution Phases

### Phase 1: High-Volume UI (Virtualization)
**Objective**: Handle 1,000,000 files with the same smoothness as VS Code.

- [ ] **Virtualized Explorer**: implement a JS Hook that only renders visible items in the file tree.
- [ ] **Optimistic Tree Toggles**: Folders rotate and "fake" expand/collapse instantly in JS.

### Phase 2: State Sovereignty (Service Layer)
**Objective**: Decouple the UI from the Scanner.

- [ ] **ProjectAgent**: A dedicated Elixir GenServer maintaining the file tree in memory (Ets).
- [ ] **Delta Bus**: Listen for OS file events (via Zig/Rust) and broadcast tiny updates.

### Phase 3: Language Intelligence (LSP Bridge)
**Objective**: Provide "Pro" features like Go-to-Definition and Linting.

- [ ] **LSP Manager**: An Elixir supervisor managing Language Server binaries.
- [ ] **Monaco Bridge**: Connect Monaco Editor to the Elixir LSP Manager via WebSockets.

### Phase 4: Native Power (Zig Upgrades)
**Objective**: Move all "Blocking" I/O to native code.

- [ ] **Zig Piece Table**: High-performance text buffer management.
- [ ] **Zig Search**: High-speed `grep` equivalent in Zig.

---

## Verification Plan

### Performance Benchmarks
- **File Load**: Explorer must handle a `node_modules` folder without frame drops.
- **Latency**: Activity bar switch must remain 0ms (Optimistic).
- **RAM**: Memory usage should stay flat during massive file scans.
