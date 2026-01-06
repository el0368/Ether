# ADR-016: Hybrid Level 5 (Native Fusion)

The "Hybrid Level 5" architecture combines the **Industrial Stability** of Level 4 (C-Shim) with the **High-Level Ergonomics** of Level 5 (Zigler Library).

## Problem
- **Level 4** (Current): Requires manual `enif_*` function mapping and pointer handling. It is "safe" but verbose and prone to boilerplate errors.
- **Level 5** (Zigler Sigil): Offers automatic type conversion but can be brittle on Windows during the linking phase.

## Solution: The Hybrid Bridge
We keep `entry.c` as the **Linker Shield** and evolve `scanner_safe.zig` to use the **Zigler Core Library** (`beam.zig`).

### Key Decisions
1. **Grafted Library**: Because Zig restrictively prevents imports outside the module path, we copy the core Zigler files from `deps/zigler/priv/beam` into our own `native/scanner/src/beam` folder.
2. **Platform Normalization**: We patch `erl_nif.zig` to use standard `erl_nif.h` instead of searching for Windows-specific variant headers that may not exist in standard OTP.
3. **Ergonomic Types**: We use `beam.env` and `beam.term` for all logic, while keeping the `export fn zig_scan` signature compatible with our manual C entry point.

### Benefits
- **Stability**: Standard C-linkage avoids DLL loading errors on Windows.
- **Safety**: Zigler's marshaling prevents manual pointer arithmetic bugs.
- **Speed**: No overhead compared to manual NIFs, just better source-level abstractions.
