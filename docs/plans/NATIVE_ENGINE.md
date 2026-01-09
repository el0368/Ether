# Master Plan: Native Engine (Zig)

## 🛡️ Core Principles (Level 5 Native)
- **Safety First:** Use `beam.allocator`, `enif_consume_timeslice`, and `enif_make_resource`.
- **Hybrid Shim:** `entry.c` handles macros, `*.zig` handles logic.
- **Fail Fast:** No Fallbacks. If Native fails, we fix Native.
- **Zero-Panic:** Complete isolation and error handling to prevent BEAM crashes (ADR-021).

---

## 🏗️ Architecture & Modular Structure

### 1. Hybrid Shim Architecture
- **The Bridge:** `entry.c` acts as a static C gateway to handle volatile Erlang NIF macros (`ERL_NIF_INIT`) on Windows.
- **The API Struct:** `WinNifApi` function-pointer struct passes BEAM functions to Zig with 100% type safety.
- **Resource Lifecycle (ADR-017):** BEAM-managed handles for persistent state (Thread Pools, Buffers).

### 2. Modular Organization
```
native/scanner/src/
├── scanner_safe.zig  # Re-export layer
├── api.zig           # WinNifApi struct & type exports
├── allocator.zig     # BeamAllocator (enif_alloc wrapper)
├── resource.zig      # Lifecycle & Destructors
├── crawler.zig       # Stack-safe iterative filesystem scan
└── searcher.zig      # Parallel content search engine
```

---

## 🔗 Native Data Pipeline
- **Unified Binary Protocol:** Symmetrical binary format: `[Type:u8][PayloadLen:u16][Payload:Bytes]`.
- **Zero-Copy Pipeline:**
  1. **Zig:** Fires binary slabs via `enif_send` directly to the LiveView process.
  2. **LiveView:** Decodes binary slabs using native Elixir pattern matching (high-speed bitstrings).
  3. **HEEx:** Renders resulting state into the DOM via Phoenix Streams.

---

## 🛡️ Stability & Safety Protocol

### 1. Stack-Safe Win32 Bypass (ADR-021)
- Bypasses `std.fs` and `std.unicode` on Windows to avoid stack-allocated UTF-16 conversions.
- Uses `nif_api.alloc` for heap paths and direct `kernel32.dll` calls for I/O.

### 2. Cooperative Scheduling
- **Timeslice Politeness:** `enif_consume_timeslice` invoked every 100 items (approx 1% slice).
- **Yield & Continue:** Iterative scanners return a reference to resume long-running operations.

### 3. Fault Tolerance
- **Defensive API:** Strict validation of binary/term types in the bridge.
- **Error Atoms:** Zig errors map consistently to Elixir atoms (e.g., `:pool_init_failed`, `:resource_limit`).

---

## 🧪 Testing & Verification Pyramid

### 1. Verification Layers
| Layer | Tool | Focus |
| :--- | :--- | :--- |
| **Unit** | `zig test` | Internal logic (Protocol, Allocators). |
| **Integrity** | `mix test` | BEAM citizenship (Memory growth, Scheduler lock). |
| **Fuzz** | `defensive_test.exs` | Boundary protection (Malformed inputs). |
| **Stress** | `stress_test.exs` | Concurrency & Volume (100k files, 100 parallel processes). |
| **Benchmark** | `Ether.Benchmark` | Regression detection vs historical baselines. |

### 2. Performance Red-Lines
- **Scanner Throughput:** Baseline **125,000 files/sec**.
- **Searcher Throughput:** Baseline **12,000 matches/sec**.
- **Tolerance:** 5% regression limit before manual review is required.

---

## 🚀 Future Roadmap

### Level 6: Intelligence (In-Progress)
- [x] **Native Content Search:** Parallel grep engine with Win32 handles.
- [ ] **Search Indexing:** Evaluation of Bloom filters or In-memory tries for instant lookup.
- [ ] **File Watcher:** Implementation of `ReadDirectoryChangesW` as a persistent resource.

### Level 7: Structured Reality
- [ ] **MessagePack Integration:** Transitioning structured agent metadata to binary serialization.
- [ ] **Tree-Sitter Embedding:** Moving syntax parsing and AST generation into the Native layer.
- [ ] **LSP Hard-Loading:** Shifting heavy LSP compute from ElixirLS to localized Zig workers.

---
*Last Updated: 2026-01-09 (Post-LiveView Migration)*
