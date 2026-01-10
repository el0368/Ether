# Deep Architectural Analysis: Frameless Windows & Custom Title Bars in Aether IDE

**Status**: Proposal (Strategy B Recommended)
**Date**: 2026-01-03
**Source**: Architecture Report (Gemini)

## 1. Executive Summary
The request for "Frameless Windows" and "Custom Title Bars" challenges the fundamental limits of the current `elixir-desktop` (wxWidgets) architecture.
While technically feasible to hack `wxWidgets`, it leads to a "Dead Window" effect or poor performance (25-30ms latency dragging).
**Recommendation**: Migrate to **Strategy B (Tauri Sidecar)**. This uses Tauri (Rust) for the UI shell (perfect frameless support) while keeping Elixir/Phoenix as the "Brain" (Sidecar).

---

## 2. The Problem: `elixir-desktop` & `wxWidgets`
Aether currently uses `elixir-desktop`, which binds to `wxWidgets` (C++).
-   **Architecture**: `Desktop.Window` -> `wxFrame` (C++) -> `wxWebView`.
-   **Paradigm**: wxWidgets wraps **Native OS Controls** (Server-Side Decorations - SSD).
-   **Conflict**: "Frameless" requires Client-Side Decorations (CSD). wxWidgets was not designed for this.

### The "Dead Window" Effect
Setting `wxBORDER_NONE` to remove the title bar results in:
1.  **Static Image**: The window loses all OS behaviors.
2.  **No Drag**: Clicking and dragging does nothing.
3.  **No Resize**: Edge dragging for resize is gone.
4.  **No Snap**: Windows Snap Layouts (Win + Arrow) stop working.
5.  **No Shadow**: Visual depth is lost.

---

## 3. Strategy A: Native Adaptation (The "Hard" Way)
*Attempting to fix `wxWidgets` without changing the stack.*

### Mechanism
1.  **Frontend (Svelte)**: Capture mouse events (`mousedown`, `mousemove`) on a custom `div`.
2.  **Network**: Send `{dx, dy}` via WebSocket to Elixir.
3.  **Backend (Elixir)**: Call `Window.move/2`.

### Latency Analysis (Why it fails Pro-Efficiency)
| Step | Time | Note |
| :--- | :--- | :--- |
| JS Event | < 1ms | |
| Serialize | 1-2ms | |
| WebSocket | 2-5ms | Loopback overhead |
| Elixir Proc | < 1ms | |
| wxWidgets NIF | 1-2ms | |
| **OS V-Sync** | **16ms** | **The Bottleneck** |
| **Total Round Trip** | **~30ms** | **Result: "Rubbery" / Laggy Drag** |

**Verdict**: Technically possible, but UX is unacceptable for a premium IDE.

---

## 4. Strategy B: Sidecar Architecture (The "Unbreakable" Way)
*Migrating to Tauri as the Shell.*

### Architecture
-   **Shell**: **Tauri (Rust)**. Handles the Window, WebView, TitleBar, Resizing, Shadow, and OS integration.
-   **Engine**: **Elixir (Burrito)**. Compiled as a single binary request handler.
-   **Communication**: Tauri spawns the Elixir Sidecar on launch.

### Why Tauri wins for Frameless?
1.  **`decorations: false`**: Native support in `tauri.conf.json`.
2.  **Hardware Dragging**: `<div data-tauri-drag-region>` delegates dragging directly to the OS (Zero Latency).
3.  **Native Resizing**: Handled by the OS/Rust layer, no WebSocket lag.
4.  **Snap Layouts**: Supported via proprietary Tauri implementations.

---

## 5. Implementation Roadmap (Strategy B)

### Phase 1: Preparation
- [ ] Bundle Aether backend using **Burrito** (Single EXE).
- [ ] Create new Tauri v2 project (`npm create tauri-app`).

### Phase 2: Migration
- [ ] Move Svelte 5 frontend from `assets/` to Tauri `src/`.
- [ ] Configure Tauri "Sidecar" to look for `aether_backend.exe`.
- [ ] Implement `CustomTitleBar.svelte` using `data-tauri-drag-region`.

### Phase 3: Cleanup
- [ ] Remove `elixir-desktop`, `wxWidgets`, and compiled C dependencies from the Elixir project.
- [ ] Update `start_dev.bat` to launch Tauri Dev Mode + Elixir Console.

---

## 6. Conclusion
**Do not use Strategy A.** It fights the platform.
**adopt Strategy B.** It leverages the best tools for each job: Rust for the Window, Elixir for the Logic.
