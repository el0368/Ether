# Zig Refactor Plan

## 🎯 Goal
Improve the maintainability, safety, and performance of the native layer by standardizing patterns and thinning the C shim.

## 🛠️ Proposed Refactors

### 1. Thin the Shim (`entry.c` ➔ `scanner.zig`)
- **Current:** `entry.c` handles some data transformation.
- **Goal:** Move all logic into Zig. Use `entry.c` ONLY for the `ERL_NIF_INIT` macro and extremely volatile C macros.
- [ ] **Test:** Ensure compilation remains stable on MSVC.

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

### 5. Thread Safety Audit
- **Current:** `ScanContext` uses a mutex for the shared buffer.
- **Goal:** Explore lock-free buffers or thread-local storage (TLS) for parallel scanning to eliminate lock contention.
- [x] **Test:** `streaming_test.exs` (Concurrency stress test - 3 parallel scans).

---

## 📈 Impact
- **Maintenance:** Easier to write new NIFs by following established patterns.
- **Performance:** Reduced overhead in parallel bursts.
- **Portability:** Ready for easier migration to other platforms if needed.
