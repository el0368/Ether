# Master Roadmap: Ether IDE

## 📍 High-Level Milestones

### Milestone 1: "The Visualizer" (Current)
**Goal:** A stable, high-performance project explorer with "Zero-Panic" native internals.
- [x] **Native Stabilization:** Stack-safe Win32 bypass and iterative scanning.
- [x] **Fair Benchmarking:** Verified 7x speedup over Elixir.
- [ ] **VS Code Aesthetic:** Complete migration from DaisyUI to native CSS variables.
- [ ] **Precise Sync:** Transition to raw binary WebSocket frames for the file tree.

### Milestone 2: "The Editor"
**Goal:** Robust file editing with multi-tab management and scannable visual cues.
- [ ] **Monaco/CodeMirror:** High-performance text editor integration.
- [ ] **Tab System:** Managing multiple open buffers with save/dirty states.
- [ ] **File Icons:** Integration of Seti/Material icon sets.

### Milestone 3: "The Intelligence"
**Goal:** Agentic AI assistance and deep language integration.
- [ ] **AI Commander:** Jido-based agent for high-level goal execution.
- [ ] **LSP Agent:** Full ElixirLS / Zig LSP integration.
- [ ] **Semantic Context:** `pgvector` storage for intelligent code context.

---

## 🏃 Project Velocity (Jan 2026)
- **Week 1:** Foundational stability. Moved from "Zigler" to "Hybrid Shim" architecture. Achieved production-ready Windows NIF status. Implemented comprehensive performance dashboard.
- **Current Focus:** Aesthetic refinement and the transition to the Milestone 2 "Editing" phase.

---

## 🐛 Active Backlog & Bug Tracker

### Critical (P0)
- [ ] **DB Restoration:** Restore `Ether.Repo` with a resilient migration/startup guard.
- [ ] **Aesthetic Debt:** Residual DaisyUI classes causing "web-app" look (refactor to VS Code vars).

### Major (P1)
- [ ] **Windows Symlinks:** Verify/Fix symlink following logic in the iterative Zig scanner.
- [ ] **Backpressure:** Refine Svelte batching engine for massive directory (100k+) rendering.

---

## ✂️ Refactor & Debt Targets
- **Logic Consolidation:** Identify and merge duplicate utility modules.
- **Agent Standardization:** Ensure all Jido agents follow strict `defaction` patterns.
- **Automated Refactoring:** Implement "Rename Module" and "Extract Function" using `Sourceror`.

---

## 🛡️ Stability Strategy
- **Crash-Only Software:** Explicit backend restarts for illegal states.
- **Zombie Killer:** Automated cleanup of PORT 4000 and orphaned BEAM processes.
- **Defensive Boundary:** Strict argument validation at the `entry.c` bridge.

---
*Last Updated: 2026-01-07*
