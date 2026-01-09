# Reference: VS Code Testing & Benchmarking Infrastructure

This document maps the testing architecture of `vscode-main` (Code - OSS) to serve as a quality blueprint for the Ether project.

## 🏛️ Test Strategy Hierarchy

| Category | Technology | Purpose | Status |
| :--- | :--- | :--- | :--- |
| **Smoke Tests** | Playwright | End-to-end UI validation. | [x] |
| **Unit Tests** | Mocha/ExUnit | Validation of core logic. | [x] |
| **MCP Tests** | Specialized | Automation of AI agent flows. | [ ] |
| **Perf Tests** | Custom/Benchee | Micro-benchmarking. | [x] |
| **Leak Tests** | Custom | Detecting memory leaks. | [x] |

---

## 🔍 Ether Gap Analysis (Current vs. VSC)

- [x] **Unit Testing**: Mature (ExUnit for BEAM, Vitest for JS).
- [x] **UI Automation (Smoke)**: Integrated Playwright suite.
- [x] **Micro-Benchmarks**: Implemented for Native Zig scanner.
- [ ] **MCP Automation**: **FUTURE**: Build `aether_mcp_test` suite.
- [ ] **Startup Telemetry**: **PLANNED**: Port `performance.ts` logic.

### 🛠️ Recommendation
Priority should be given to **LSP Diagnostics Integration** and **Memory/Performance Monitoring** via the Phoenix Dashboard.

## ✅ Playwright E2E Testing (Implemented)

Ether now uses **Playwright** for comprehensive UI/UX testing.

### Test Suites
- [x] **Layout Verification** (`tests/e2e/layout.spec.ts`)
- [x] **File Explorer** (`tests/e2e/file-explorer.spec.ts`)
- [x] **QuickPicker** (`tests/e2e/quick-picker.spec.ts`)
- [x] **Editor** (`tests/e2e/editor.spec.ts`)

---
*Last Updated: 2026-01-09*
