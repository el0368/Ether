# Ether Frontend: Stability & Performance Constitution

This document defines the high-level engineering standards for all frontend development within the Ether IDE. Stability and Performance are NOT features; they are foundational requirements.

## 1. Rune Discipline (Svelte 5)

### State Management
- **Rule of Locality**: Keep `$state` as close to the usage as possible.
- **Raw by Default**: Use `$state.raw` for large data objects (like the file tree or Monaco content) that do not require deep reactivity. This prevents massive overhead.
- **Class-Based Logic**: Prefer class-based state modules (like `UIState`, `EditorState`) over plain objects. This enforces a clear API and encapsulation.

### Derivations & Effects
- **Pure Derivations**: `$derived` runes must be pure and side-effect free.
- **Effect Restraint**: Use `$effect` ONLY for side effects (syncing with DOM, external APIs). Do NOT use effects to update state that could be handled by `$derived`.
- **Cleanup Requirement**: Every `$effect` must return a cleanup function to prevent memory leaks, especially when dealing with event listeners or timers.

## 2. Unbreakable UI (Stability)

### Error Boundaries
- **Component isolation**: Wrap major UI zones (Sidebar, Editor, Terminal) in Error Boundaries to ensure a failure in one does not crash the entire workbench.
- **Graceful Degradation**: When a component fails, display a "Reload Component" button rather than a white screen.

### Defensive Props
- **Type Safety**: Use TypeScript interfaces for all component props.
- **Presence Check**: Always verify the existence of complex objects (e.g., `activeFile?.path`) before accessing properties.

## 3. Performance & Benchmarks

### Reactivity Budgets
- **Frame Rate**: The UI must maintain 60FPS during typing and navigation.
- **Latency Monitoring**: Any interaction taking longer than 16ms (1 frame) must be reported to the internal `PerformanceMonitor`.

### Reactive Pressure (System Pressure ADR-005)
- **Batching**: Rapid-fire data from the backend (like file tree chunks) MUST be batched using a `flushBatch` pattern to prevent UI locking.
- **Lazy Ignition**: All heavy data requests must wait for the initial UI paint (minimum 800ms) to ensure instant "Perceived Performance."

## 4. Testing & Verification

### The Testing Pyramid
1. **Unit Tests (Vitest)**: For logical state classes (`ui.svelte.js`, `editor.svelte.js`).
2. **Integration Tests**: Connectivity and Channel logic.
3. **E2E (Playwright)**: Critical paths (File Open -> Edit -> Save).

### No Technical Debt
- Code that is hard to test is considered technical debt and should be refactored immediately.
