# Ether Frontend: Stability & Performance Constitution (LiveView Edition)

This document defines the high-level engineering standards for the Ether IDE UI. Stability and Performance are NOT features; they are foundational requirements.

## 1. LiveView Discipline (Elixir-First)

### State Management
- **Rule of Locality**: Keep assigns in the specific LiveComponent or LiveView that owns the data.
- **Minimal Diffs**: Avoid massive socket assigns. Use `Phoenix.LiveView.stream/3` for large collections (file trees, logs) to ensure the server only sends minimal patches to the client.
- **No Client State**: All UI decisions (visibility, active files) should be managed as Server Assigns to eliminate synchronization bugs between frontend and backend.

### Concurrency & Backpressure
- **Rate-Limiting**: High-frequency events (binary scanner chunks) must be processed into manageable UI updates (batching in the GenServer loop).
- **Asynchronous Work**: Time-consuming IO (opening large files) must use `Task.async` or specialized Agents to prevent blocking the LiveView process.

## 2. Unbreakable UI (Stability)

### Process Isolation
- **Individual GenServers**: Every major UI feature (File Tree, LSP, Terminal) is backed by its own GenServer agent. A crash in one agent does not bring down the IDE shell.
- **Auto-Recovery**: Use Supervisor strategies to automatically restart failed agent processes and restore the UI state gracefully.

### Defensive Rendering
- **Pattern Matching**: Use Elixir pattern matching in HEEx templates to handle `@active_file == nil` or error states without crashing.
- **Fail-Safe Defaults**: Provide sensible default values for all assigns.

## 3. Performance & Benchmarks

### Reactivity Budgets
- **Frame Rate**: The Monaco Editor (via JS Hook) must maintain 60FPS. All state updates from LiveView must be lightweight enough to avoid JANK in the editor.
- **Socket Latency**: Local socket communication (Tauri <-> LiveView) must aim for <1ms latency for instant "Perceived Performance."

### System Pressure (ADR-005)
- **Throttling**: Rapid-fire telemetry or scan data MUST be throttled to prevent Event Loop starvation in the browser engine.
- **Lazy Loading**: Complex UI panels should be loaded on-demand using `phx-trigger-action` or conditional rendering.

## 4. Testing & Verification

### The Unified Testing Stack
1. **LiveView Tests (ExUnit)**: Comprehensive verification of UI state and rendering logic (replaces Vitest/Svelte tests).
2. **Native Integrity (Zig)**: Verifying memory safety of the scanner NIF.
3. **Telemetry Benchmarks**: Real-time measurements using `Telemetry` and `Benchee`.

### No Technical Debt
- Code that requires manual JSON serialization for internal communication is considered technical debt. Use the direct BEAM process-to-process communication.

---
*Last Updated: 2026-01-09 (Post-LiveView Migration)*
