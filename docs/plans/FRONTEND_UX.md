# Master Plan: Frontend & UX (Phoenix LiveView)

## 🎨 Design Philosophy: "Native-First"
Ether aims for a premium, high-performance desktop feel. We avoid generic web-app aesthetics.

- [x] **Stack:** Phoenix LiveView + Tailwind CSS + Heroicons.
- [x] **Unified Engine:** All UI state resides in the Elixir GenServer (Socket Assigns).
- [x] **Direct Backend Access:** UI elements talk directly to Backend Agents.

---

## ⚡ Reactivity & State Management
- [x] **Socket Assigns:** Single source of truth for workspace state.
- [x] **Phoenix Streams:** O(1) rendering for the file tree.
- [x] **JS Hooks:** Narrowly focused Interop for Monaco Editor and Xterm.js.

---

## 🔗 High-Performance Sync Pipeline
The path from Disk to DOM is now unified within the Erlang runtime.

### 1. Direct Scanner Integration
- [x] **Binary Slabs:** Native Zig Scanner pushes binary chunks to LiveView.
- [x] **Native Decoding:** LiveView decodes scanner binaries using pattern matching.
- [x] **Performance Target:** <50ms initial sync for 10k files.

### 2. LiveView Streams
- [x] **Smart Patching**: Phoenix Streams handle insertions/deletions automatically.
- [x] **Zero-JavaScript logic**: File tree expansion handled in pure Elixir.

---

## 🚧 Feature Roadmap & Priority

### 🔥 P0: Foundation (COMPLETED)
- [x] **VS Code Theme:** standard CSS tokens for IDE identity.
- [x] **LiveView Shell:** Replaced Svelte frontend with `WorkbenchLive`.
- [x] **Monaco Bridge:** High-performance JS Hook for the editor.

### ⚡ P1: Polish & Interaction (IN PROGRESS)
- [x] **Zero-Lag Highlighting**: CSS-based path highlighting for 100k+ files.
- [x] **Optimized Editor Sync**: 1000ms debouncing for large file stability.
- [/] **LSP Integration**: Real-time diagnostics into the LiveView UI.
- [ ] **Integrated Terminal**: Streaming `CommandAgent` output via Xterm.js Hook.
- [ ] **Advanced QuickPick**: Unified search/palette using LiveView search-as-you-type.

---

## 🛡️ Performance Red-Lines
- [x] **Memory:** <500KB additional RAM per 10k tracked elements in the LiveView Stream.
- [x] **Latency:** Sub-10ms UI update for state-driven interactions.
- [x] **Communication:** Eliminate all manual JSON serialization.

---
*Last Updated: 2026-01-09 (Post-LiveView Migration)*
