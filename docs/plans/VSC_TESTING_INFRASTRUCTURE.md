# Reference: VS Code Testing & Benchmarking Infrastructure

This document maps the testing architecture of `vscode-main` (Code - OSS) to serve as a quality blueprint for the Ether project.

## 🏛️ Test Strategy Hierarchy

| Category | Location | Technology | Purpose |
| :--- | :--- | :--- | :--- |
| **Smoke Tests** | `test/smoke` | Playwright | End-to-end UI validation and "happy path" checks. |
| **Unit Tests** | `test/unit` | Mocha | Validation of core logic and utility functions. |
| **MCP Tests** | `test/mcp` | Specialized | Automation of AI agent flows, transports, and multi-server orchestration. |
| **Perf Tests** | `src/**/*.perf.test.ts` | Custom | Micro-benchmarking of high-frequency code paths (e.g., fuzzy searching). |
| **Leak Tests** | `test/leaks` | Custom | Detecting memory and handle leaks in the Electron environment. |

## 📊 Performance Analytics
- **Startup Metrics**: Logged via `src/vs/base/common/performance.ts`.
- **Timeline Events**: Telemetry points for every major lifecycle event (e.g., `willStartWorkbench`).
- **Profiling**: Automated profiling logic found in `test/mcp/src/profiler.ts`.

---

## 🔍 Ether Gap Analysis (Current vs. VSC)

| Infrastructure Item | VS Code Status | Ether Status | Action |
| :--- | :--- | :--- | :--- |
| **Unit Testing** | Mature (Mocha) | Mature (Vitest/Mix) | No immediate action. |
| **UI Automation (Smoke)** | Mature (Playwright) | **EMPTY** | **CRITICAL**: Integrate Playwright. |
| **Micro-Benchmarks** | Integrated (`.perf`) | **EMPTY** | **IMPORTANT**: Implement `perfTest()` primitive. |
| **MCP Automation** | Advanced (Native) | **EMPTY** | **FUTURE**: Build `aether_mcp_test` suite. |
| **Startup Telemetry** | Native Registry | Minimal | **PLANNED**: Port `performance.ts` logic. |

### 🛠️ Recommendation
Priority should be given to **Playwright integration** (Phase II/III) and **Micro-benchmarking** (for the native Zig scanner) to ensure Ether maintains "VS Code level" responsiveness as it grows.
