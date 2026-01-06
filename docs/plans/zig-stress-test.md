# Zig Native Scanner: Stress Test Protocol

## 🎯 Objective
Verify the stability, performance, and resource safety of `scanner_nif.dll` under extreme load conditions.
Target metric: **Zero Crashes, Zero Leaks** under 100x normal load.

## 🧪 Experiments

### 1. Volume Stress (The "Monolith" Test)
**Scenario**: Scan a massive directory structure (>100,000 files).
**Mechanism**:
- Generate a deep/wide temp directory tree (Depth: 10, Width: 10).
- Populate with 100k dummy files.
- Run `Scanner.scan_raw` and `Scanner.search`.
**Success Criteria**:
- Completion < 2 seconds.
- Memory usage delta < 50MB.

### 2. Concurrency Storm (The "C100" Test)
**Scenario**: 100 concurrent Elixir processes requesting scans simultaneously.
**Mechanism**:
- `Task.async_stream` spawning 100 requestors.
- All target different or same directories.
**Success Criteria**:
- `ScannerResource` thread pool handles queueing without deadlocks.
- All tasks return `{:ok, ...}`.

### 3. The Endurance Run (Memory Leak Check)
**Scenario**: Continuous scanning for 60 seconds.
**Mechanism**:
- Loop `scan` command 10,000 times.
**Success Criteria**:
- Validates the `BeamAllocator` handles fragmentation.
- `observer` shows stable NIF memory usage.

### 4. The "Kill Switch" (Resilience)
**Scenario**: Hard termination of the calling process during an active scan.
**Mechanism**:
- Spawn process -> Start Scan -> `Process.exit(pid, :kill)`.
**Success Criteria**:
- NIF does not crash the entire VM (Segfault).
- `ScannerResource` destructor cleans up the thread pool eventually (GC).

## 🛠️ Implementation
Will be implemented in `test/ether/native/stress_test.exs` with `@tag :stress` (excluded from default `mix test`).

## 📊 Benchmarks
We will track:
- **Throughput**: Files scanned per second.
- **Latency**: Time to first byte (TTFB) for streaming.
- **Overhead**: RAM usage per 1k files.
