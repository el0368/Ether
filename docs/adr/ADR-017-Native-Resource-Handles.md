# ADR-017: Native Resource Handles

## Context
Our current NIFs are "stateless"—we call `scan`, it finds files, and it finishes. "Level 6" features like **Content Indexing** require persistent state (e.g., an open database or a cached search index).

## Decision
We will implement **BEAM Resources**. 

### How it works:
1. **Creation**: Zig creates a struct (e.g., `SearchContext`) and registers it with the BEAM via `enif_alloc_resource`.
2. **Handoff**: Zig returns the pointer to Elixir. Elixir sees this as an opaque "Reference."
3. **Safety**: As long as Elixir holds the reference, the native memory is safe. When Elixir's Garbage Collector hits the reference, it automatically calls a **Zig Destructor** to clean up the native memory.

### Implementation Pattern (Hybrid Level 5/6):
We will add `enif_alloc_resource_type` to our `WinNifApi` in `entry.c` so our Zig code can create these "Smart Pointers" safely.

## Consequences
- **Positive**: No memory leaks. Elixir manages the lifecycle of native objects.
- **Positive**: Enables "Level 6" persistent search engines.
- **Complexity**: Requires a destructor function in Zig to prevent dangling handles.
