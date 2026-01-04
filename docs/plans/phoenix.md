# Phoenix Roadmap

## 🔥 Core Strategy (Phoenix 1.8+)
- **Channels:** The high-speed bridge between Elixir and Svelte.
- **Presence:** Tracking which users/windows are editing which files.
- **No HTML:** We use Phoenix *strictly* as a WebSocket / JSON API. No `.heex` templates for UI, only Svelte.

## ✅ Completed
- [x] **Connection:** `UserSocket` and `EditorChannel` working.
- [x] **Binary Streaming:** Raw socket pushes for NIF data (`{:binary, data}`).
- [x] **Port 4000:** Standard dev port, resilient startup.

## 🚧 Roadmap
- [ ] **Phase 1: Code Intelligence API**
  - `editor:hover` -> Returns types/docs.
  - `editor:definition` -> Returns file location.
  - Requires LSP Agent integration.

- [ ] **Phase 2: Presence Tracking**
  - Who is in this file? (Collaborative editing foundation).
  - Sync cursor positions.

- [ ] **Phase 3: Telemetry**
  - LiveDashboard integration for performance monitoring (NIF memory usage).
