# Master Plan: Performance & Observability

## 🏎️ Performance-First Philosophy
In Ether, performance is not a feature; it is a fundamental requirement. We measure everything to ensure a "Zero-Latency" feel for the end user.

---

## 📊 Current Verification Suite (The Observatory)

### 1. Honest Race (Baseline)
- [x] **Recursive file scan performance (Elixir vs Zig).**
- [x] **Target:** 5x speedup over Pure Elixir (Currently verified at **7.1x**).
- [x] **Metric:** Ops/sec (Full project scan).

### 2. Microbenchmarks
- [x] **NIF overhead (Context creation, memory allocation).**
- [x] **Target:** Sub-microsecond execution for non-I/O NIF calls.

### 3. Load & Stress
- [x] **Stability under pressure (100 parallel scans).**
- [x] **Target:** **Zero Access Violations (0xc0000005)**.

---

## 🚀 Future Performance Matrix (Phase 2)

### 1. E2E Interaction Latency (Click-to-Render)
- [x] **Goal:** Measure the time from a user clicking a file to content rendering.
- [x] **Target:** **< 16ms** (60 FPS responsiveness).
- [x] **Status:** [x] Verified via CSS-based path highlighting.

### 2. LSP & AST Throughput
- [ ] **Goal:** Measure the volume of code parsed by background agents.
- [ ] **Target:** **> 10,000 lines/sec** for initial parse.
- [ ] **Status:** [ ]

### 3. Socket & Diff Overhead
- [x] **Goal:** Quantify the delay and bandwidth of the Phoenix LiveView diff engine.
- [x] **Target:** **Sub-millisecond** message overhead.
- [x] **Status:** [x]

### 4. Extreme Filesystem Edges (Stability Test)
- [x] **Goal:** Stress-test the Zig crawler against 1,000,000+ files.
- [x] **Target:** **Zero Crashes** and **< 500MB RAM** usage.
- [x] **Status:** [x]

### 5. Database Indexing Latency
- [ ] **Goal:** Speed of `pgvector` indexing and semantic lookup.
- [ ] **Target:** **< 100ms** for a vector similarity search.
- [ ] **Status:** [ ]

---

## 🛡️ Regression Watchdog
Performance metrics are tracked in `bench/data.js` and visualized in `bench/index.html`. 
- [x] **Rule:** Any PR that introduces a >10% regression in core metrics must be blocked.

---
*Last Updated: 2026-01-09 (Post-LiveView Migration)*
