# ADR-019: Zig-Elixir Capability Maturity Model (Levels 1-6)

## Status
**ACCEPTED** - Defined on 2026-01-06.

## Context
As the project evolves its native integration, we need a common vocabulary to describe the depth and safety of the fusion between Zig and the Elixir/BEAM runtime. This model tracks the progression from external processes to native "intelligence."

## The Maturity Levels

### Level 1: The Opaque Porter
*   **Mechanism**: `System.cmd` or `Port.open`.
*   **Implementation**: Standalone Zig executable communicating via STDIN/STDOUT.
*   **Security/Safety**: 100% Isolation. Zig crashes do not affect the VM.
*   **Performance**: Low (High overhead due to context switching and data copying).

### Level 2: The Raw NIF (Foreigner)
*   **Mechanism**: Shared library (`.dll`/`.so`) loaded via `erl_nif`.
*   **Implementation**: Direct use of `enif_*` functions from Zig.
*   **Security/Safety**: Dangerous. Illegal memory access crashes the entire VM.
*   **Performance**: High (Direct memory access).

### Level 3: The Good Citizen (Manual Safety)
*   **Mechanism**: `BeamAllocator` + `enif_consume_timeslice`.
*   **Implementation**: Manual wrapping of allocators and CPU time reporting.
*   **Security/Safety**: Improved visibility. Memory usage appears in Erlang's `:observer`.
*   **Performance**: High (Safe performance without scheduler starvation).

### Level 4: The Industrial Shim
*   **Mechanism**: C-Shim Gateway (`entry.c`) + API Function Struct.
*   **Implementation**: C handles Erlang macros for stability; Zig handles pure logic.
*   **Security/Safety**: High Build Stability (essential for Windows/MSVC compatibility).
*   **Performance**: High.

### Level 5: The Native Fusion
*   **Mechanism**: High-Level Type Marshalling (e.g., Zigler behavior).
*   **Implementation**: Automatic conversion between Zig types and Elixir terms.
*   **Security/Safety**: High Developer Ergonomics; reduced manual pointer errors.
*   **Performance**: High.
*   **Hybrid Note**: Our current state (Hybrid Level 5) uses Level 4 stability with Level 5 logic.

### Level 6: Maximum Intel (Persistent Intelligence)
*   **Mechanism**: BEAM Resources + Thread-Local Environments + Zero-Copy.
*   **Implementation**: Native objects managed by Elixir GC; background worker threads streaming to pids.
*   **Security/Safety**: Mature resource management (no memory leaks).
*   **Performance**: Maximum (Zero-copy data transfer and parallel asynchronous messaging).

## Consequences
- This model will be used in future ADRs and planning documents to specify the architectural "Level" of any proposed native feature.
