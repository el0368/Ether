# ADR-017: Native Resource Handles

## Status
**IN PROGRESS** - Implementation planned 2026-01-06.

## Context
Our current NIFs are "stateless"—we call `scan`, it finds files, and it finishes. "Level 6" features like **Content Indexing** require persistent state (e.g., an open database or a cached search index).

## Decision
We will implement **BEAM Resources**.

### How it works:
1. **Creation**: Zig creates a struct (e.g., `SearchContext`) and registers it with the BEAM via `enif_alloc_resource`.
2. **Handoff**: Zig returns the pointer to Elixir. Elixir sees this as an opaque "Reference."
3. **Safety**: When Elixir's GC collects the reference, it calls a **Zig Destructor** to clean up native memory.

---

## Proposed Changes

### [MODIFY] entry.c
Add wrappers for resource management functions:
- `enif_open_resource_type` (on NIF load)
- `enif_alloc_resource`
- `enif_release_resource`
- `enif_make_resource`

### [MODIFY] scanner_safe.zig
Add new fields to `WinNifApi`:
- `open_resource_type`
- `alloc_resource`
- `release_resource`
- `make_resource`

Create destructor function:
```zig
export fn resource_destructor(env: ?*ErlNifEnv, obj: *anyopaque) void {
    // Free any native memory held by the resource
}
```

### [NEW] lib/ether/native/search_context.ex
Elixir module to manage resource lifecycle:
- `new/1` - Create a new search context
- `close/1` - Explicitly release the resource

### [NEW] test/ether/native/resource_test.exs
Tests for resource lifecycle:
- Create resource, hold reference, verify no crash
- Drop reference, force GC, verify destructor runs
- Kill owning process, verify native memory freed

---

## Verification Plan
1. [ ] Create resource, verify Elixir receives valid reference.
2. [ ] Hold reference in process, verify no memory leak.
3. [ ] Drop reference + `:erlang.garbage_collect()`, verify destructor called.
4. [ ] Kill process holding resource, verify cleanup via destructor.

## Consequences
- **Positive**: No memory leaks. Elixir manages the lifecycle of native objects.
- **Positive**: Enables "Level 6" persistent search engines.
- **Complexity**: Requires destructor function in Zig.
