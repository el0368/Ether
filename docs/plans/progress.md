# Progress Log & Milestones

This document tracks the high-level velocity of the project.

## 📅 January 2026

### Week 1 (Jan 1 - Jan 7): The "Native" Foundation
- [x] **Jan 04:** 🏗️ **Infrastructure & DX**:
  - Overhauled `start_dev.bat`: Added zombie process cleanup (Port 4000) and removed database dependency for resilient startup.
  - Verified stability of Frontend-Backend bridge via Phoenix Channels.
- [x] **Jan 04:** 📚 **Strategic Documentation Refactor**:
  - Centralized fragmentation into `docs/plans/` (11 specialized roadmaps).
  - Created root `ROADMAP.md` central index and updated `AGENTS.md` / `TEST_COVERAGE.md`.
- [x] **Jan 04:** 🛡️ **Zig Hardening Milestone**:
  - Elaborated "Safe Shim" architecture and "Level 4 Citizenship" (Memory tracking & Timeslice Politeness).
  - Defined "Ultimate Stability" (Phase 5) roadmap for zero-panic NIF execution.
- [x] **Jan 03:** ⚡ **Async NIF**: Implemented `enif_send` for Zig Scanner.
- [x] **Jan 02:** 🧱 **Hybrid Shim**: Moved to `entry.c` + `scanner.zig` for Windows stability.

## 📅 Milestone Targets

### Milestone 1: "The Visualizer" (Current)
- **Goal:** Working read-only file explorer with VS Code aesthetics.
- **Remaining:**
  - [ ] Theme Migration (VS Code Dark).
  - [ ] File Icons.
  - [ ] Zero-Copy pipeline optimization.

### Milestone 2: "The Editor"
- **Goal:** Opening and editing files.
- **Requirements:**
  - [ ] Text Editor Component (Monaco/CodeMirror).
  - [ ] File Read/Write Agents.
  - [ ] Tab Management System.

### Milestone 3: "The Intelligence"
- **Goal:** AI assistance and LSP.
- **Requirements:**
  - [ ] AI Command Agent.
  - [ ] LSP Agent (Go to Def).
  - [ ] Vector Memory.
