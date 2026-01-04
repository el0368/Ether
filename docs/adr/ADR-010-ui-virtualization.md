# ADR-010: UI Virtualization for Infinite Scale

## Context
Diagnosis (2026-01-04) revealed that rendering thousands of file nodes directly into the DOM (O(N) Rendering) causes severe performance degradation ("DOM Avalanche"). To support large repositories ("Infinite Scale") while maintaining "Antigravity" fluidity, we must decouple rendering cost from data size.

## Decision
We implement **Mandatory UI Virtualization** for all list-based views.

1.  **Virtual Scroller:** Instead of rendering all items, we render only the subset currently visible in the viewport.
2.  **Fixed Row Height:** We enforce a fixed row height (e.g., 28px) to enable O(1) position calculation.
3.  **State-Driven Slicing:** Using Svelte 5 Runes (`$state`, `$derived`), we dynamically slice the data array based on the container's `scrollTop`.
4.  **Ghost Buffer:** A minimal shim element simulates the total scrollable height to preserve native scrollbar behavior.

## Consequences
### Positive
*   ✅ **Infinite Scalability:** Rendering performance is O(VisibleItems), typically constant (~30 nodes), regardless of dataset size (10k or 1m).
*   ✅ **Memory Efficiency:** Drastic reduction in DOM node count reduces browser memory footprint.
*   ✅ **Fluidity:** Eliminates layout thrashing during scroll, enabling 60fps+ performance.

### Negative
*   ❌ **Fixed Height Constraint:** Elements must vary in height, which simplifies the editor UI but limits flexibility for complex rich-text feeds (acceptable for file trees).
*   🟡 **Search/Ctrl+F:** Native browser `Ctrl+F` will not find items that are not currently rendered. (Mitigation: Use the built-in Command Palette/Search).

## Status
Accepted
