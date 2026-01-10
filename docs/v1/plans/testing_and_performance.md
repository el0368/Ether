# Testing & Performance Plan (Ether)

Establish a "Zero-Lag" performance testing suite for the Svelte 5 + LiveView + Bun hybrid architecture.

## Part 1: Testing Infrastructure

### [NEW] Vitest + Bun Runner
- Configure **Vitest** to use **Bun** for near-instant test execution.
- Target: `assets/vitest.config.ts`.

### [NEW] Vitest Browser Mode
- Integrate `vitest-browser-svelte` driver.
- Purpose: Measure "Typing Experience" by timing the gap between `keydown` and DOM mutation.

### [NEW] Playwright E2E
- Focus on the **Elixir-to-Svelte Bridge**.
- Test: Simulate Zig engine update in Elixir -> verify UI update in < 16ms.

---

### [Part 2] Performance Auditing

#### [NEW] [Layout.svelte](file:///c:/GitHub/Ether/assets/svelte/Layout.svelte)
- Inject **`svelte-render-scan`** in `dev` mode.
- Visualize re-renders to ensure editor typing doesn't affect the Sidebar or Activity Bar.

#### [NEW] [editor.bench.ts](file:///c:/GitHub/Ether/assets/tests/editor.bench.ts)
- Use `bun:test` benchmarks.
- Measure:
    - Piece Table logic performance.
    - Elixir Prop -> Svelte Rune conversion speed.

---

### [Part 3] Static Analysis

#### `svelte-check`
- Run deep static analysis to detect memory leaks, unused reactive dependencies, or "dirty" reactivity patterns.

## Verification Goals

| Metric | Target |
| --- | --- |
| **Typing Latency** | < 8ms (JS) |
| **Bridge Flush** | < 16ms (Server to UI) |
| **Render Efficiency** | 0 unrelated re-renders during typing |
| **Large Tree Scroll** | 60 FPS (1,000+ files) |
