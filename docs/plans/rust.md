# Rust (Tauri) Roadmap

## 🦀 Core Strategy
- **Role:** The "Shell" of the application.
- **Responsibility:**
  - Window Management (Draggable regions, Resizing).
  - Native Menus (File, Edit, View).
  - System Tray.
  - Global Shortcuts.
- **Philosophy:** Keep the Rust layer *thin*. It delegates mostly to the Webview (Svelte) or spawns the Backend (Elixir).

## ✅ Completed
- [x] **Tauri v2:** Project is initialized with Tauri 2.0.
- [x] **Sidecar:** Configured to launch the Elixir Backend (`start_dev.bat` orchestrates this for dev).
- [x] **Command CLI:** `cargo tauri` integration.

## 🚧 Roadmap

### Phase 1: Window Aesthetics
- [ ] **Frameless Window:** Remove the Windows title bar.
- [ ] **Acrylic/Mica:** Enable Windows 11 translucency effects behind the sidebar.
- [ ] **Draggable Regions:** `data-tauri-drag-region` implementation for the custom title bar.

### Phase 2: Native Integration
- [ ] **System Menus:** Restore standard "File/Edit" menus that disappeared with frameless mode.
- [ ] **File Associations:** Double-clicking `.ex` files opens Ether.
- [ ] **Single Instance Lock:** Prevent multiple instances of the IDE opening.

### Phase 3: Performance
- [ ] **Custom Protocol:** Register `ether://` protocol for deep links.
- [ ] **IPC Hardening:** Audit allowlist for frontend-to-rust commands.
