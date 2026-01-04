# Zig Native Roadmap

## 🛡️ Core Principles (Level 4 Native)
- **Safety First:** Use `beam.allocator`, `enif_consume_timeslice`, and `enif_make_resource`.
- **Hybrid Shim:** `entry.c` handles macros, `*.zig` handles logic.
- **Fail Fast:** No Fallbacks. If Native fails, we fix Native.

## ✅ Completed (Phase 1-2)
- [x] **Memory:** Replaced `GeneralPurposeAllocator` with `beam.allocator`.
- [x] **Scheduling:** Implemented `enif_consume_timeslice` (1% per 100 ticks).
- [x] **Async:** Implemented `enif_send` for non-blocking file streaming.
- [x] **Unicode:** Full support for Emoji paths (`🚀`) via `lib/std`.
- [x] **Windows:** Native `entry.c` shim for correct dll compilation.

## ⚠️ In Progress (Phase 3-4)
- [ ] **Zero-Copy Pipeline:** Ensure Elixir does NOT decode binaries, just passes them.
- [ ] **Binary Realloc:** Shrink large memory slabs using `enif_realloc_binary`.

## 🚀 Future (Phase 6+)
- [ ] **File Watcher:** Implement `ReadDirectoryChangesW` (Windows) in Zig.
- [ ] **Content Search:** Ripgrep-style parallel text search (~1GB/s target).
- [ ] **Tree-Sitter:** Embed syntax parsing for instant code intelligence.

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
