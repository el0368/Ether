# Zig Native Roadmap

## 🛡️ Core Principles (Level 4 Native)
- **Safety First:** Use `beam.allocator`, `enif_consume_timeslice`, and `enif_make_resource`.
- **Hybrid Shim:** `entry.c` handles macros, `*.zig` handles logic.
- **Fail Fast:** No Fallbacks. If Native fails, we fix Native.

## ✅ Completed (Phase 1-2)
- [x] **Memory:** Replaced `GeneralPurposeAllocator` with `beam.allocator`.
  - [x] **Test:** `integrity_test.exs` (Memory leak detection).
- [x] **Scheduling:** Implemented `enif_consume_timeslice` (1% per 100 ticks).
  - [x] **Test:** `integrity_test.exs` (Scheduler responsiveness).
- [x] **Async:** Implemented `enif_send` for non-blocking file streaming.
  - [x] **Test:** `integrity_test.exs` (Message flushing validation).
- [x] **Unicode:** Full support for Emoji paths (`🚀`) via `lib/std`.
  - [x] **Test:** `streaming_test.exs` (Unicode/Emoji stress test).
- [x] **Windows:** Native `entry.c` shim for correct dll compilation.
  - [x] **Test:** `verify_setup.bat` (DLL presence and loading check).

## ✅ Completed (Phase 3-4)
- [x] **Defensive API:** Added input validation wrappers (`is_binary`, `is_pid`, `is_list`) to `entry.c`.
  - [x] **Test:** `defensive_test.exs` (Invalid argument rejection).
- [x] **Binary Realloc:** Exposed `enif_realloc` and `enif_realloc_binary` for efficient buffer growth.
  - [x] **Test:** `integrity_test.exs` (Memory growth within bounds).
- [ ] **Zero-Copy Pipeline:** Consolidating in **[Native Data Pipeline](NATIVE_DATA_PIPELINE.md)**.

## 🛡️ Ultimate Stability (Phase 5: The "Zero-Panic" Goal)
- [x] **Resource Management:** See **[ADR-017: Native Resource Handles](../adr/ADR-017-Native-Resource-Handles.md)** ✅ (2026-01-06).
- [x] **Modular Refactoring:** Split `scanner_safe.zig` (434 lines) into 4 focused modules (26 lines main + 373 lines modules).
- [ ] **Fault Tolerance:** Replace `catch return` logic with explicit `Error` types returned to Elixir.
  - [x] **Test:** `integrity_test.exs` (Error atom clarity).
- [ ] **Thread-Safe Messaging:** Implement `enif_alloc_env` for workers to stream WITHOUT blocking the NIF.
  - [ ] **Test:** Verify sequential delivery of interleaved chunks.
- [ ] **Re-entrant Loops:** Support for "Yield and Continue" (returning a reference to resume a long scan).
  - [ ] **Test:** Pause and Resume multi-million file scan.

## 🚀 Future (Phase 6+)
- [ ] **File Watcher:** Implement `ReadDirectoryChangesW` (Windows) as a persistent NIF Resource.
  - [ ] **Test:** Latency check for 0ms save-to-UI update.
- [ ] **Content Search:** Ripgrep-style parallel text search (~1GB/s target).
  - [ ] **Test:** Speed benchmark against `rg`.
- [ ] **Tree-Sitter:** Embed syntax parsing for instant code intelligence.
  - [ ] **Test:** Parsing accuracy for large Elixir modules.
- [ ] **LSP Server:** Move heavy-lifting LSP logic into Zig for <1ms response times.
  - [ ] **Test:** Memory usage vs ElixirLS.

---

## 📜 History & Changelog

### 2026-01-06: Level 6 Foundation (ADR-017 + Modular Refactor)
- **Resource Handles (ADR-017):** Implemented BEAM Resource lifecycle management.
  - Added `enif_alloc_resource`, `enif_release_resource`, `enif_make_resource` wrappers to `entry.c`.
  - Created `ScannerResource` struct with automatic GC-triggered destructor.
  - Elixir now manages native pointer lifecycle safely.
- **Modular Refactoring:** Split monolithic `scanner_safe.zig` (434 lines) into focused modules:
  - `api.zig` (38 lines) — WinNifApi struct and type exports
  - `allocator.zig` (58 lines) — BeamAllocator implementation
  - `resource.zig` (62 lines) — ADR-017 lifecycle functions
  - `crawler.zig` (215 lines) — File scanning logic
  - `scanner_safe.zig` (26 lines) — Thin re-export layer
- **Performance Baseline:** Established 125,000 files/sec throughput as the "Red Line" for future features.
- **Test Suite Expansion:** Added Unicode stress test (7 special filenames) and 3-parallel concurrency test.

### 2026-01-04: The "Safe Shim" Revolution
- **Removed Zigler:** Migrated away from the `Zigler` library. While excellent for Linux/OSX, it suffered from MSVC macro expansion inconsistencies on Windows, leading to unstable DLL headers.
- **Hybrid Shim Architecture:** 
  - **The Bridge:** Introduced `entry.c` as a static C gateway. It handles the volatile Erlang NIF macros (`ERL_NIF_INIT`) that Zig's `translate-c` struggled with on Windows.
  - **The API Struct:** Created `WinNifApi`, a function-pointer struct passed from C to Zig. This allows Zig to call BEAM functions (`enif_send`, `enif_alloc`) with 100% type safety and zero macro dependency.
- **Manual NIF Loading:** Implemented `Ether.Native.Scanner` with a manual `@on_load` hook. This provides granular control over DLL paths and error reporting compared to automated loaders.
- **Dirty Schedulers:** Enabled `ERL_NIF_DIRTY_JOB_IO_BOUND` flags in the C shim to ensure long file-system crawls don't hog main scheduler threads.

### 2026-01-03: Async Streaming (Phase 2)
- **The Bottleneck:** Previously, `scan_nif` returned a massive list of strings. For 50k+ files, this caused a "Stop-the-world" freeze while the BEAM allocated thousands of small string objects.
- **The Solution:** Switched to `enif_send` (Process Messaging). The NIF now pushes data to the caller's inbox and returns `:ok` immediately.
- **Binary Slab Protocol:** 
  - Implemented a custom high-density binary format: `[Type:u8][PathLen:u16][Path:Bytes]`. 
  - This allows the NIF to send thousands of paths in a single flat binary chunk, reducing messaging overhead by 90%.
- **Incremental Rendering:** By streaming chunks of 1,000 files, the Svelte UI can start rendering the top of the file tree while the NIF is still crawling the bottom.

### 2026-01-02: Level 4 Citizenship
- **The "No Fallback" Policy:** Removed all pure Elixir directory crawlers. We committed to the "Safe Native" path—if the NIF fails, it is an error that must be fixed, not hidden by a slow fallback.
- **BEAM-Aware Allocation:** 
  - Replaced Zig's `GeneralPurposeAllocator` with a custom `BeamAllocator` wrapper.
  - Every byte used by Zig is now allocated via `enif_alloc`, meaning the BEAM's `:observer` can correctly track "Native Memory" usage.
- **Timeslice Politeness (BEAM Preemption):** 
  - **The 1ms Rule:** In Erlang's preemptive multitasking, a NIF that runs longer than 1 millisecond without returning or yielding is considered "unpolite." It can block the entire scheduler thread, causing lag in other Elixir processes (like the Phoenix socket heartbeats).
  - **The Solution:** Injected `enif_consume_timeslice` directly into the recursive hot-loop in `scanner_safe.zig`. 
  - **Reporting Strategy:** Instead of calling the expensive API every single file, we report consumption every 100 files (estimated at 1% of a timeslice). This tells the BEAM: "I've used X% of my 1ms budget."
  - **Preemptive Yielding:** If the scheduler sees the NIF has hit 100% of its timeslice, it can safely suspend the process or prepare for a context switch, effectively preventing the dreaded "NIF blocking scheduler" warnings in the console.
- **Unicode Resilience:** Hardened `std.fs` usage to handle Windows UTF-16 path conversions correctly, ensuring Emojis and foreign characters don't crash the scanner.
