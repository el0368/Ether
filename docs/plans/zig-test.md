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
- [ ] **Error Clarity:** Ensure every Zig error maps to an Elixir atom.

### 3. Fuzz Testing (Boundary Protection)
Stress testing the `entry.c` bridge.
- [ ] **Argument Fuzzing:** Send random terms (maps, numbers, deep lists) to `scan_raw`.
- [ ] **Protocol Fuzzing:** Send malformed binary slabs to the Svelte decoder.

### 4. Stress & Concurrency Tests
- [ ] **Massive Directory Scan:** Test on `C:/Windows/` or `node_modules` (500k+ files).
- [ ] **Parallel Contention:** Run 10 parallel scans to check for race conditions.
- [ ] **Process Death:** Kill the scanning process and verify NIF cleanup via Resource Destructors.

### 5. Benchmark Suite
- [ ] **Latency:** Compare `list_raw` vs `File.ls_r` (Target: 10x speedup).
- [ ] **Throughput:** MB/s of directory metadata processed.

---

## 🛠️ Tools
- `zig test`: For unit level.
- `mix test`: For integration level.
- `Aether.Benchmark`: For performance tracking.
