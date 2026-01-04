# Frontend (Svelte) Roadmap

## 🎨 Core Principles
- **Svelte 5:** Use Runes (`$state`, `$effect`) for all state management.
- **Virtualization:** Rendering millions of items requires `VirtualList`.
- **Aesthetic:** VS Code Dark Theme (No DaisyUI).

## ✅ Completed
- [x] **Connection:** Stable WebSocket to Phoenix (Port 4000).
- [x] **File Explorer:** Virtualized list rendering 30k+ files.
- [x] **Binary Decoder:** TypeScript `NifDecoder` for zero-copy format.

## 🚧 In Progress
- [ ] **Theme:** Migration from DaisyUI to VS Code variables.
- [ ] **Icons:** File type icons (Seti/Material).
- [ ] **Tab System:** Managing multiple open files.

## 🔮 Future
- [ ] **Editor:** Integrate Monaco, CodeMirror, or a custom Svelte editor.
- [ ] **Terminal UI:** Xterm.js integration.
- [ ] **Frameless Window:** Custom title bar with Tauri.
