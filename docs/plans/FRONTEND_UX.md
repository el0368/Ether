# Master Plan: Frontend & UX (Phoenix LiveView)

## 🎨 Design Philosophy: "Native-First"
Ether aims for a premium, high-performance desktop feel. We avoid generic web-app aesthetics in favor of a customized VS Code-inspired dark theme. By using LiveView, we eliminate the "Context-Switch Tax" and "Polyglot Fatigue."

- **Stack:** Phoenix LiveView + Tailwind CSS + Heroicons.
- **Unified Engine:** All UI state resides in the Elixir GenServer (Socket Assigns), eliminating the need for client-side stores.
- **Direct Backend Access:** UI elements talk directly to Backend Agents (FileServer, Testing) without intermediary APIs.

---

## ⚡ Reactivity & State Management
We lead with server-side reactivity, leveraging the BEAM's inherent stability.

- **Socket Assigns:** Single source of truth for visibility, active files, and workspace state.
- **Phoenix Streams:** O(1) rendering for the file tree and massive lists, managing data efficiently on the server and over the wire.
- **JS Hooks:** Narrowly focused Interop for heavy-weight web components (Monaco Editor, Xterm.js).

---

## 🔗 High-Performance Sync Pipeline
The path from Disk to DOM is now unified within the Erlang runtime.

### 1. Direct Scanner Integration
- **Binary Slabs:** The Native Zig Scanner pushes binary chunks directly to the LiveView process.
- **Native Decoding:** LiveView decodes scanner binaries using `<<...>>` pattern matching (the fastest way to parse binary in Elixir).
- **Performance Target:** <50ms initial sync for 10k files across the backend-frontend boundary.

### 2. LiveView Streams
- **Smart Patching**: Phoenix Streams handle insertions and deletions automatically via standard DOM patching.
- **Zero-JavaScript logic**: File tree expansion and selection logic are handled in pure Elixir.

---

## 🚧 Feature Roadmap & Priority

### 🔥 P0: Foundation (COMPLETED)
- [x] **VS Code Theme:** standard CSS tokens for IDE identity.
- [x] **LiveView Shell:** Replaced Svelte frontend with `WorkbenchLive`.
- [x] **Monaco Bridge:** High-performance JS Hook for the editor.

### ⚡ P1: Polish & Interaction (IN PROGRESS)
- [ ] **LSP Integration**: Real-time diagnostics from the Elixir LS agent directly into the LiveView UI.
- [ ] **Integrated Terminal**: Streaming `CommandAgent` output via Xterm.js Hook.
- [ ] **Advanced QuickPick**: Unified search/palette using LiveView search-as-you-type.

---

## 🛡️ Performance Red-Lines
- **Memory:** <500KB additional RAM per 10k tracked elements in the LiveView Stream.
- **Latency:** Sub-10ms UI update for state-driven interactions (toggle sidebar, menu).
- **Communication:** Eliminate all manual JSON serialization for internal IDE state.

---
*Last Updated: 2026-01-09 (Post-LiveView Migration)*
