# ZIG BEAM AUDIT: Native Code Citizenship

This document tracks the "citizenship status" of our Zig NIF code within the BEAM ecosystem.

## 🏛️ The Three Laws of BEAM Citizenship

### 1. Time-Slicing (Politeness)
> "A good citizen shares resources with others."

| Status | Description |
|--------|-------------|
| ✅ PASS | Calling `enif_consume_timeslice(env, 1)` every 100 iterations |

**Current**: NIF reports 1% timeslice consumption every 100 file iterations.
**Impact**: BEAM scheduler can rebalance work across cores during long scans.

### 2. Resource Reaping (Responsibility)
> "A good citizen cleans up after themselves."

| Status | Description |
|--------|-------------|
| ✅ PASS | Using `std.fs` which auto-closes handles in `defer` |

**Current**: `dir.close()` in `defer` block ensures cleanup.
**Future**: Implement NIF Resource Destructors for long-lived handles.

### 3. Binary Reference Counting (Awareness)
> "A good citizen understands memory ownership."

| Status | Description |
|--------|-------------|
| ⚠️ PARTIAL | Returning large slabs that may be referenced by small slices |

**Current**: Frontend may hold small references to large binary slabs.
**Target**: Implement `enif_realloc_binary` for size reduction when appropriate.

---

## 📊 Evidence Tests

| Test | Location | Status |
|------|----------|--------|
| Memory Leak Detection | `test/ether/native/integrity_test.exs` | ✅ |
| Scheduler Blocking | `test/ether/native/integrity_test.exs` | ✅ |
| Error Clarity | `test/ether/native/integrity_test.exs` | ✅ |

---

## 🎯 Action Items (Phase 18+)

1. [x] **Time-Slice Yielding**: Validated dynamic yielding in `scan_yield_nif` (Phase 2 Fix).
2. [x] **Resource Destructors**: Implemented safe `zig_resource_destructor` with memory cleanup (Phase 3).
3. [ ] **Binary Compaction**: Implement `realloc_binary` for sub-1KB extracts from large slabs.

---

## 🏆 Current Status: Hybrid Level 5 (The Native Fusion)
We have achieved **Level 5** characteristics by combining the stability of our C-Shim (Level 4) with the ergonomic safety of our Resource Helpers (Level 5).
- **Safety**: Double-Free protection in `BeamAllocator`.
- **Latency**: Sub-1ms yielding verified.
- **Protocol**: High-Performance Binary (TLV).

---

## 📖 References

- [Erlang NIF Best Practices](https://www.erlang.org/doc/man/erl_nif.html)
- [Zigler Documentation](https://hexdocs.pm/zigler)
- [BEAM Book - Schedulers](https://blog.stenmans.org/theBeamBook/)

> "Fast is good. Polite is better. Polite AND fast is elite."
