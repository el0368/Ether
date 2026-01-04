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
