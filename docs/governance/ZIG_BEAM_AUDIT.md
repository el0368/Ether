# ZIG BEAM AUDIT: Native Code Citizenship

This document tracks the "citizenship status" of our Zig NIF code within the BEAM ecosystem.

## 🏛️ The Three Laws of BEAM Citizenship

### 1. Time-Slicing (Politeness)
> "A good citizen shares resources with others."

| Status | Description |
|--------|-------------|
| ⚠️ PARTIAL | Using `@dirty_cpu` but NOT yielding via `enif_consume_timeslice` |

**Current**: NIF can monopolize a Dirty CPU core for long operations.
**Target**: Periodically yield using time-slice consumption checks.

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
| Memory Leak Detection | `test/aether/native/integrity_test.exs` | ✅ |
| Scheduler Blocking | `test/aether/native/integrity_test.exs` | ✅ |
| Error Clarity | `test/aether/native/integrity_test.exs` | ✅ |

---

## 🎯 Action Items (Phase 18+)

1. **Time-Slice Yielding**: Add `consume_timeslice` check every N iterations in scan loop
2. **Resource Destructors**: Register cleanup callbacks for external handles
3. **Binary Compaction**: Implement `realloc_binary` for sub-1KB extracts from large slabs

---

## 📖 References

- [Erlang NIF Best Practices](https://www.erlang.org/doc/man/erl_nif.html)
- [Zigler Documentation](https://hexdocs.pm/zigler)
- [BEAM Book - Schedulers](https://blog.stenmans.org/theBeamBook/)

> "Fast is good. Polite is better. Polite AND fast is elite."
