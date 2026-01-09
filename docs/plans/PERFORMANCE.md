# Master Plan: Performance & Observability

## 🏎️ Performance-First Philosophy
In Ether, performance is not a feature; it is a fundamental requirement. We measure everything to ensure a "Zero-Latency" feel for the end user.

---

## 📊 Current Verification Suite (The Observatory)

### 1. Honest Race (Baseline)
- **Focus:** Recursive file scan performance (Elixir vs Zig).
- **Target:** 5x speedup over Pure Elixir (Currently verified at **7.1x**).
- **Metric:** Ops/sec (Full project scan).

### 2. Microbenchmarks
- **Focus:** NIF overhead (Context creation, memory allocation).
- **Target:** Sub-microsecond execution for non-I/O NIF calls.

### 3. Load & Stress
- **Focus:** Stability under pressure (100 parallel scans).
- **Target:** **Zero Access Violations (0xc0000005)**.

---

## 🚀 Future Performance Matrix (Phase 2)

### 1. E2E Interaction Latency (Click-to-Render)
- **Goal:** Measure the time from a user clicking a file in the sidebar to the content rendering in the editor.
- **Target:** **< 16ms** (Necessary for a "Snap" feel and 60 FPS responsiveness).
- **Why:** If latency exceeds 16ms, the user perceives the lag, breaking the "Premium" immersion.

### 2. LSP & AST Throughput
- **Goal:** Measure the volume of code (lines/sec) parsed and analyzed by our background agents.
- **Target:** **> 10,000 lines/sec** for initial parse; **< 50ms** for incremental AST updates.
- **Why:** Instant syntax highlighting and "Go to Definition" require extreme parsing speed on every keystroke.

### 3. Socket & Diff Overhead
- **Goal:** Quantify the delay and bandwidth of the Phoenix LiveView diff engine.
- **Target:** **Sub-millisecond** message overhead; **< 1KB** diffs for high-frequency updates (e.g., cursor position).
- **Why:** Large-scale IDEs generate thousands of events (diagnostics, file updates). Phoenix Streams ensure O(1) rendering regardless of collection size.

### 4. Extreme Filesystem Edges (Stability Test)
- **Goal:** Stress-test the Zig crawler against 1,000,000+ files and circular symbolic links.
- **Target:** **Zero Crashes** and **< 500MB RAM** usage at peak volume.
- **Why:** Prevents the "White Screen of Death" when opening massive enterprise monorepos.

### 5. Database Indexing Latency
- **Goal:** Speed of `pgvector` indexing and semantic lookup for AI features.
- **Target:** **< 100ms** for a vector similarity search across a 100k-chunk codebase.
- **Why:** AI code search must feel as fast as a standard `CTRL+F` text search.

---

## 🛡️ Regression Watchdog
Performance metrics are tracked in `bench/data.js` and visualized in `bench/index.html`. 
- **Rule:** Any PR that introduces a >10% regression in core metrics must be blocked for architectural review.

---
*Last Updated: 2026-01-09 (Post-LiveView Migration)*
