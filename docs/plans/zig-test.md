# Zig Testing Plan

## 🎯 Goal
Ensure 100% reliability and BEAM-safety of the native layer through a multi-layered testing strategy.

## 🧪 Testing Pyramid

### 1. Zig Unit Tests (`std.testing`)
Tests internal Zig logic without the BEAM environment.
- [ ] **Binary Serialization:** Test `AetherProtocol` packing/unpacking accuracy.
- [ ] **Path Handling:** Verify Unicode and long-path edge cases in `std.fs` wrappers.
- [ ] **Allocators:** Verify `BeamAllocator` doesn't leak under simulated OOM.

### 2. Integrity Tests (Elixir + NIF)
Verified via `integrity_test.exs`. Proves the NIF is a "Good Citizen."
- [x] **Memory Integrity:** 1,000+ iterations without RAM growth.
- [x] **Scheduler Politeness:** Verify no blocking > 1ms.
- [x] **Error Clarity:** Ensure Zig errors map to atoms (`:pool_init_failed`, `:search_failed`).

### 3. Fuzz Testing (Boundary Protection)
Stress testing the `entry.c` bridge.
- [x] **Argument Fuzzing:** `defensive_test.exs` (rejection of invalid types).
- [ ] **Protocol Fuzzing:** Send malformed binary slabs to the Svelte decoder.

### 4. Stress & Concurrency Tests
- [ ] **Massive Directory Scan:** Test on `C:/Windows/` or `node_modules` (500k+ files).
- [x] **Parallel Contention:** `ScannerResource` Thread Pool verification.
- [ ] **Process Death:** Kill the scanning process and verify NIF cleanup via Resource Destructors.

### 5. Content Search Tests (Level 6)
Verified via `search_test.exs`.
- [x] **Sync Search:** Finds exact string matches.
- [x] **Recursive Search:** Finds matches deep in nested directories.
- [x] **Zero Results:** Correctly handles empty result sets.

### 6. Benchmark Suite
- [ ] **Latency:** Compare `list_raw` vs `File.ls_r` (Target: 10x speedup).
- [x] **Throughput:** **125,000 files/sec** (Baseline 2026-01-06).

---

## 🛠️ Tools
- `zig test`: For unit level.
- `mix test`: For integration level.
- `Ether.Benchmark`: For performance tracking.
