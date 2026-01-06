# Zig Refactor Plan

## 🎯 Goal
Improve the maintainability, safety, and performance of the native layer by standardizing patterns and thinning the C shim.

## 🛠️ Proposed Refactors

### 1. Thin the Shim (`entry.c` → `scanner.zig`) ✅
- **Current:** `entry.c` handles only macro wrappers and NIF registration.
- **Completed (2026-01-06):** Moved all logic into modular Zig files. `entry.c` now only contains `ERL_NIF_INIT` and volatile C macros.
- [x] **Test:** Build succeeds on MSVC with 10/10 tests passing.

### 1.1 Modular Structure (NEW)
```
native/scanner/src/
├── scanner_safe.zig  # 26 lines - Re-export layer
├── api.zig           # 38 lines - WinNifApi struct
├── allocator.zig     # 58 lines - BeamAllocator
├── resource.zig      # 62 lines - ADR-017 lifecycle
└── crawler.zig       # 215 lines - File scanning logic
```

### 2. Standardized Error Handling
- **Current:** Zig returns `make_atom(env, "error_string")`.
- **Goal:** Implement a `Result(T)` pattern in Zig that maps to `{:ok, T} | {:error, reason}` in Elixir consistently.
- [ ] **Test:** `integrity_test.exs` (Error handling cases).

### 3. Allocator Enhancements
- **Current:** `BeamAllocator` assumes no in-place resize.
- **Goal:** Properly implement `resize` and `remap` using `enif_realloc` if possible, or ensure Zig's `ArrayList` handles growth efficiently via `beam.allocator`.
- [ ] **Test:** Benchmark allocation speed during massive directory walks.

### 4. Binary Slab Consolidation
- **Current:** Each NIF (Scanner, Search, etc.) might implement its own binary format.
- **Goal:** Create a shared `AetherProtocol` Zig module for consistent binary serialization.
- [ ] **Test:** Verify cross-compatibility between different NIFs and the Svelte `nif_decoder.ts`.

### 5. Thread Safety Audit ✅
- **Current:** `ScanContext` uses a mutex for the shared buffer.
- **Status:** Verified with 3-parallel scan stress test.
- [x] **Test:** `streaming_test.exs` (Concurrency stress test - 3 parallel scans).

---

## 📈 Impact
- **Maintenance:** Easier to write new NIFs by following established patterns.
- **Performance:** Reduced overhead in parallel bursts.
- **Portability:** Ready for easier migration to other platforms if needed.
