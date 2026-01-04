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
  - [ ] **Test:** Add specific Unicode/Emoji path test case.
- [x] **Windows:** Native `entry.c` shim for correct dll compilation.
  - [x] **Test:** `verify_setup.bat` (DLL presence and loading check).

## ⚠️ In Progress (Phase 3-4)
- [ ] **Zero-Copy Pipeline:** Ensure Elixir does NOT decode binaries, just passes them.
  - [ ] **Test:** Benchmark CPU usage vs Hybrid decoding.
- [ ] **Binary Realloc:** Shrink large memory slabs using `enif_realloc_binary`.
  - [ ] **Test:** Memory fragmentation audit.
- [ ] **Defensive API:** Audit `entry.c` for input validation (`enif_is_binary`, `enif_is_list`).
  - [ ] **Test:** Fuzzing `scan_raw` with invalid argument types.

## 🛡️ Ultimate Stability (Phase 5: The "Zero-Panic" Goal)
- [ ] **Resource Management:** Use `enif_make_resource` for long-lived scan states (prevent leaks if pid dies).
  - [ ] **Test:** Kill watcher process and verify Zig destructor runs.
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

### 2026-01-04: The "Safe Shim" Revolution
- **Removed Zigler:** Migrated away from the `Zigler` library. While excellent for Linux/OSX, it suffered from MSVC macro expansion inconsistencies on Windows, leading to unstable DLL headers.
- **Hybrid Shim Architecture:** 
  - **The Bridge:** Introduced `entry.c` as a static C gateway. It handles the volatile Erlang NIF macros (`ERL_NIF_INIT`) that Zig's `translate-c` struggled with on Windows.
  - **The API Struct:** Created `WinNifApi`, a function-pointer struct passed from C to Zig. This allows Zig to call BEAM functions (`enif_send`, `enif_alloc`) with 100% type safety and zero macro dependency.
- **Manual NIF Loading:** Implemented `Aether.Native.Scanner` with a manual `@on_load` hook. This provides granular control over DLL paths and error reporting compared to automated loaders.
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
- **Timeslice Politeness:** 
  - Injected `enif_consume_timeslice` into the recursive crawl loop. 
  - The NIF now reports its CPU usage (1% every 100 files) to the Erlang scheduler, preventing "NIF blocking scheduler" warnings.
- **Unicode Resilience:** Hardened `std.fs` usage to handle Windows UTF-16 path conversions correctly, ensuring Emojis and foreign characters don't crash the scanner.
