# Aether IDE - Master Roadmap

**Status:** Active Development
**Goal:** Build a high-performance, AI-native IDE using the SPEL Stack (Svelte, Phoenix, Elixir, Lucide) + Zig/Rust.

---

## 1. Zig (Native Core) ⚡
**Focus:** Ultra-fast file operations and system integration.

### Phase 1: Foundation (✅ COMPLETE)
- [x] **Safe Memory Management**: Replaced `GPA` with `beam.allocator` for leak-free operations.
- [x] **Scheduler Cooperation**: Implemented `enif_consume_timeslice` to prevent BEAM stutters.
- [x] **Unicode Support**: Full UTF-8 path handling on Windows.

### Phase 2: Async Streaming (✅ COMPLETE)
- [x] **Chunked Messaging**: Sends results in batches (1000 files/chunk).
- [x] **Async Protocol**: Uses `enif_send` to push data to Elixir processes.

### Phase 3: Future Optimization (Planned)
- [ ] **Binary Compaction**: Implement `enif_realloc_binary` to shrink large slabs.
- [ ] **Native Watcher**: Use `ReadDirectoryChangesW` for high-performance file watching.
- [ ] **Ripgrep Search**: Implement content searching within the Zig NIF context.

---

## 2. Elixir (Backend) 💧
**Focus:** Orchestration, AI Agents, and Business Logic.

### Core Architecture (✅ COMPLETE)
- [x] **Agent System**: GenServer-based agents (FileServer, Scanner, Shell).
- [x] **Phoenix Channels**: Real-time communication with Frontend.
- [x] **Hybrid Startup**: `start_dev.bat` for robust Windows launching.

### Features (Planned)
- [ ] **Pipeline Squeeze**: Optimize `Scanner.ex` for true Zero-Copy pass-through (currently hybrid).
- [ ] **LSP Integration**: `LSPAgent` to wrap language servers (ElixirLS, TSServer).
- [ ] **AI Orchestration**: `RefactorAgent` using Sourceror for automated code rewrites.

---

## 3. Svelte (Frontend) 🧡
**Focus:** UI/UX, Virtualization, and Terminal.

### Visuals (🚧 IN PROGRESS)
- [x] **UI Virtualization**: Virtual List for managing 100k+ files (Implemented in `FileExplorer`).
- [ ] **VS Code Theme**: Migrate from DaisyUI to custom CSS variables (`--vscode-editor-background`).
- [ ] **Icon Theme**: Implement Seti/Material icons for files.

### Components (Planned)
- [ ] **Terminal**: Integrate xterm.js for a real embedded terminal.
- [ ] **Tabs/Panes**: Draggable layout system.
- [ ] **Command Palette**: `Ctrl+P` modal for quick file navigation.

---

## 4. Rust / Tauri (Shell) 🦀
**Focus:** OS Window Management and Navigation.

### Windowing (Planned)
- [ ] **Frameless Window**: Custom title bar with native controls.
- [ ] **Multi-Window**: Support detaching tabs into new windows.
- [ ] **System Tray**: Background operation support.

---

## 5. PostgreSQL (Data) 🐘
**Focus:** Indexing and Search.

### Database (Planned)
- [ ] **Re-enable Repo**: Uncomment `Aether.Repo` once stable.
- [ ] **Search Index**: Store file metadata and embeddings for semantic search.
- [ ] **User Preferences**: Persist workspace state and theme settings.

---

## 6. Miscellaneous (Docs & DevEx)
- [x] **Dev Scripts**: `check_env.bat`, `verify_setup.bat`.
- [ ] **CI/CD**: GitHub Actions for automated testing and NIF compilation.
