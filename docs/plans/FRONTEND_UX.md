# Master Plan: Frontend & UX (Svelte 5)

## 🎨 Design Philosophy: "Native-First"
Ether aims for a premium, high-performance desktop feel. We avoid generic web-app aesthetics in favor of a customized VS Code-inspired dark theme.

- **Stack:** Svelte 5 (Runes) + Tailwind v4 (Oxide) + Lucide Icons.
- **No Component Libraries:** We are removing DaisyUI in favor of raw CSS variables and Tailwind utilities to maintain total control over the look and feel.
- **Virtualized Lists:** Rendering 100k+ files requires strict virtualization (no DOM bloat).

---

## ⚡ Reactivity & State Management
We use Svelte 5 Runes for fine-grained, high-performance reactivity.

- **`$state`:** All global and component state.
- **`$effect`:** Used sparingly for side effects (e.g., updating the OS window title).
- **Batching:** High-frequency events (like scanning 1k files/sec) are batched to a 20 FPS refresh rate to prevent main-thread starvation.

---

## 🔗 High-Performance Sync Pipeline
The path from Disk to DOM must be as direct as possible.

### 1. Zero-Copy Decoder
- **Binary Slabs:** Svelte receives raw binary chunks (AetherProtocol) from the Phoenix Channel.
- **NifDecoder:** TypeScript-optimized decoder transforms binary directly into JSON-like structures for the store.
- **Performance Target:** <100ms initial sync for 10k files.

### 2. Delta Engine
- **Smart Merging:** Instead of replacing the tree, incoming `filetree:delta` events are merged in-place using indexed lookups.
- **Performance Target:** <5ms from disk-write to UI-update.

---

## 🚧 Feature Roadmap & Priority

### 🔥 P0: Foundation (Milestone 1)
- [ ] **VS Code Theme:** Define `--vscode-*` variables and refactor all components to use them.
- [ ] **DaisyUI Removal:** Finalize the cleanup of all library-dependent classes.
- [ ] **Raw Binary Frames:** Switch from Base64 to raw binary on the WebSocket for the file tree.

### ⚡ P1: Polish & Interaction
- [ ] **File Icons:** Integration of Seti/Material icon sets for improved scannability.
- [ ] **Resizing Layout:** Robust split-pane management for Sidebar/Editor.
- [ ] **Tabs & Navigation:** Simple tab bar for managing multiple open buffers.

### 🚀 P3: Advanced Capabilities
- [ ] **The Editor:** Integration of Monaco or CodeMirror as the primary IDE buffer.
- [ ] **Native Terminal:** Embedding Xterm.js for the `CommandAgent` output.
- [ ] **Frameless Window:** Custom title bar styling via Tauri `window-start-dragging`.

---

## 🛡️ Performance Red-Lines
- **Memory:** <1MB additional RAM per 10k tracked elements in the Svelte store.
- **Frame Rate:** Zero drops below 60fps during UI interactions.
- **Latency:** Sub-10ms UI update for all local user interactions.

---
*Last Updated: 2026-01-07*
