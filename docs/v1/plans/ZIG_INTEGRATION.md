# Architecture: SPEL-AI Native Synergy (Zig + LiveView)

## 🏗️ The Bridge Architecture

We use a **Hybrid Shim + Binary Slabs** architecture to eliminate serialization overhead and ensure Windows compatibility.

### 1. Zero-Copy Pipeline
- **Native Slabs**: Zig emits high-density binary buffers (`ErlNifBinary`) containing multiple entries.
- **Bitstream Decoding**: Elixir pattern matches directly on these buffers in `O(1)` time per entry.
- **LiveView Streams**: Decoded items are pushed into LiveView `streams` for efficient DOM diffing.

### 2. LiveView <-> Zig Resource Lifecycle
- **Sticky Resources**: Store Zig handles (Search, Git, Indexers) in LiveView socket assigns or dedicated Agents.
- **Auto-Cleanup**: BEAM destructors ensure Zig resources are freed when Elixir processes terminate.

## 📍 Integration Phases

### Phase I: The Scanner Rewrite (LiveView Optimized) [COMPLETED]
- [x] **Chunked Delivery**: Modify `Ether.Native.Scanner` to deliver "slabs" (500 items/chunk).
- [x] **Binary Depth Calculation**: Calculate tree depth in Zig to save Elixir CPU cycles.

### Phase II: The Agent Bridge (Current Focus) [/]
- [ ] **RefactorAgent**: Connect Zig syntax-tree parsing (Tree-Sitter) for 10x refactor speed.
- [ ] **SearchAgent**: Parallel multi-threaded `grep` in Zig, streaming to `GlobalSearch`.

### Phase III: DX & Stability [COMPLETED]
- [x] **Unified Build**: Automate Zig compilation with `mix compile` integration.
- [x] **Fail-Safe**: Yieldable NIFs with `is_active` checks to prevent scheduler locks.
- [x] **Unbreakable Builds**: "Shadow-Copying" logic in Mix task to allow native updates while app is running.

---
> [!IMPORTANT]
> **Policy**: NO ELIXIR FALLBACK. Zig is the core of the engine.
