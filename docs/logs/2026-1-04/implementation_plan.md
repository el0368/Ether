# Master Execution Plan: Zero-Copy Data Pipeline

## Goal Description
Transform Aether's file scanning architecture from a synchronous "Wait-and-See" model to an asynchronous "Streaming Data" pipeline (144Hz target). This involves deep Zig/BEAM integration, Zero-Copy data transfer, and incremental frontend rendering.

## User Review Required
> [!IMPORTANT]
> This is a major architectural rewrite. It introduces async messaging (`enif_send`) and strictly managed memory allocation (`beam.allocator`) in the Native NIF.

## Phase 1: Native Foundation (Zig Level) - ✅ COMPLETE
**Objective:** Make Zig stable, memory-safe, and cooperative with the BEAM scheduler.

### [MODIFY] [scanner_safe.zig](file:///c:/Users/Administrator/Documents/GitHub/Ether/native/scanner/src/scanner_safe.zig)
- ✅ **Memory:** Replace `std.heap.GeneralPurposeAllocator` with `beam.allocator`.
- ✅ **Scheduling:** Inject `enif_consume_timeslice` into the recursive directory walk to prevent scheduler starvation.

## Phase 2: Asynchronous Reflex (Messaging Level) - ✅ COMPLETE
**Objective:** Switch from return values to message passing.

### [MODIFY] [scanner_safe.zig](file:///c:/Users/Administrator/Documents/GitHub/Ether/native/scanner/src/scanner_safe.zig)
- ✅ **Streaming:** Implement explicit Chunking (e.g., send results every 1000 files).
- ✅ **Messaging:** Use `enif_send` to push binary chunks to the caller's process inbox.
- ✅ **Protocol:** Send a final `{:scan_completed}` atom to signal stream end.

## Phase 3: Pipeline Squeeze (Elixir Level) - ⚠️ PARTIAL
**Objective:** Propagate data from NIF to Frontend with Zero CPU overhead.

### [MODIFY] [scanner.ex](file:///c:/Users/Administrator/Documents/GitHub/Ether/lib/aether/scanner.ex)
- ⚠️ **Receiver:** Logic exists but currently decodes binary in Elixir (Hybrid Apprroach) instead of pure Zero-Copy pass-through.
- ⬜ **Pass-through:** Forward binary chunks directly to Phoenix Channels (`{:binary, slab}`) without decoding to terms/JSON.

## Phase 4: Client-Side Decoder (Frontend) - ✅ COMPLETE
**Objective:** Handle high-speed binary streams in Svelte.

### [MODIFY] [nif_decoder.ts]
- ✅ **Buffering:** Implement a buffer to stitch binary chunks into a smooth stream.
- ✅ **Rendering:** Update Svelte 5 `$state` incrementally to avoid UI frozing.

## Phase 5: Evidence & Validation - ⬜ PENDING
**Objective:** Verify stability and performance.

### [NEW] [memory_torture_test.exs]
- ⬜ **Stress Test:** Rapidly trigger scans to verify `beam.allocator` frees memory correctly (Stable RAM baseline).

### [NEW] [benchmark_fcp.exs]
- ⬜ **Metric:** Measure "Time to First File" (Goal: < 5ms).
