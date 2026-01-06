# Plan: Phase 6 Safety & Performance Shield

## 🎯 Goal
Implement "Level 6" Native Intelligence (Content Search) without degrading the performance or stability of the existing "Level 5" Scanner.

## 🛡️ Stability Strategy: "The Great Wall"

### 1. Hard Module Isolation
- **Structure**: Move crawler logic to `src/native/crawler.zig` and search logic to `src/native/searcher.zig`.
- **Interface**: The `zig_scan` entry point will remain untouched. A new `zig_search` entry point will be created.
- **Guarantee**: A crash or OOM in the Searcher cannot corrupt the Crawler's state because they share no mutable memory.

### 2. Resource Priority & Fairness
- **Thread Pool Partitioning**: 
  - Crawler: Guaranteed baseline of 2 threads.
  - Searcher: Uses "Elastic" threads (up to MAX-2) but yields to Crawler requests.
- **BEAM Backpressure**:
  - Implement a `CHUNKS_PER_SECOND` limit for Search results to prevent the Svelte store from freezing during high-velocity text matching.

### 3. Memory Guardrails
- **Pre-allocation limits**: Search buffers will have a hard cap (e.g., 64MB). If a file exceeds this or cumulative usage is too high, the Searcher returns `{:error, :resource_limit}` instead of crashing.
- **Resource Handles (ADR-017)**: Every search session is tied to a BEAM Resource. If the Elixir process dies, Zig **must** immediately free all associated buffers.

## 📈 Performance Regression Testing
We will add a "Performance Watchdog" to `test/ether/native/integrity_test.exs`:
1. **Baseline**: Measure standard scan speed of `/node_modules`.
2. **Under Load**: Run a heavy content search simultaneously.
3. **Requirement**: Standard scan speed must not drop by more than **5%** while search is active.

## 🛠️ Implementation Phasing
- **Phase 6.1 (Shielding)**: Expand tests and split Zig modules.
- **Phase 6.2 (Resource handles)**: Implement ADR-017.
- **Phase 6.3 (Search logic)**: Implement the actual grep-engine.
- **Phase 6.4 (Verification)**: Run high-concurrency stress tests.
