# Ether IDE: Master Roadmap

## 🎯 The North Star: The Dual-Purpose Engine
> [!IMPORTANT]
> **Definitive Strategy:** The combined vision for Ether is now documented in the **[GRAND_MASTER_PLAN.md](file:///c:/GitHub/Ether/docs/plans/GRAND_MASTER_PLAN.md)**.

## 📍 High-Level Milestones

### Milestone 1: "The Visualizer" (Current)
**Goal:** A stable, high-performance project explorer with "Zero-Panic" native internals.
- [x] **Native Stabilization:** Stack-safe Win32 bypass and iterative scanning.
- [x] **Fair Benchmarking:** Verified 7x speedup over Elixir.
- [ ] **Performance Master Plan:** Formalized observability roadmap in [PERFORMANCE.md](PERFORMANCE.md).
- [ ] **VS Code Aesthetic:** Complete migration from DaisyUI to native CSS variables.
- [ ] **Precise Sync:** Transition to raw binary WebSocket frames for the file tree.

### Milestone 2: "The Editor"
**Goal:** Robust file editing with multi-tab management and scannable visual cues.
> [!NOTE]
> Progress on this milestone depends on the **[VSC_IDE_STUDY.md](VSC_IDE_STUDY.md)** phased analysis.

- [ ] **Monaco/CodeMirror:** High-performance text editor integration.
- [ ] **Tab System:** Managing multiple open buffers with save/dirty states.
- [ ] **File Icons:** Integration of Seti/Material icon sets.

### Milestone 3: "The Intelligence"
**Goal:** Agentic AI assistance and deep language integration.
- [ ] **AI Commander:** Jido-based agent for high-level goal execution.
- [ ] **LSP Agent:** Full ElixirLS / Zig LSP integration.
- [ ] **Semantic Context:** `pgvector` storage for intelligent code context.

### Milestone 4: "The Cloud/Hybrid"
**Goal:** Run Ether in a browser with full local-to-cloud synchronization.
- [ ] **Web-First Shell:** Ensure 100% feature parity between Tauri and standard Browser.
- [ ] **Remote Workspace:** Support for mounting remote SSH or Volume-based repositories.
- [ ] **Shared Intelligence:** Syncing AI context and vector data between desktop and cloud instances.

### Milestone 5: "The Self-Evolving IDE"
**Goal:** An IDE that maintains and updates itself without external aid.
- [ ] **Self-Repair Loop:** Internal Gemini Agent detects and fixes its own technical debt.
- [ ] **Production-Grade Updates:** Automated binary releases via Tauri/GitHub Actions.
- [ ] **Recursive Architecture:** Using Ether to build the next version of Ether.

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
*Last Updated: 2026-01-08*
