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
- **Removed Zigler:** We moved away from `Zigler` macros due to compilation instability on Windows.
- **Hybrid Shim Architecture:** Introduced `entry.c` to handle Erlang NIF macros (`ERL_NIF_INIT`), while keeping logic in pure `scanner.zig`.
- **Manual NIF Loading:** Implemented `Aether.Native.Scanner` to load the DLL safely using `:erlang.load_nif/2`.

### 2026-01-03: Async Streaming (Phase 2)
- **Problem:** Synchronous scanning froze the BEAM VM on large directories (`node_modules`).
- **Solution:** Implemented `enif_send`.
- **Protocol:** `{:binary, Blob}` chunks are flushed every 1000 files, followed by `{:scan_completed, :ok}`.

### 2026-01-02: Level 4 Citizenship
- **Allocator:** Replaced Zig's GPA with `beam.allocator` to prevent memory leaks and let the VM track NIF memory usage.
- **Timeslices:** Added `enif_consume_timeslice` to the hot loop to stay polite to other Process schedulers.
