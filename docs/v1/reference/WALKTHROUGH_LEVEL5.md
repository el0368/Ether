# Walkthrough: Hybrid Level 5 (Native Fusion)

Date: 2026-01-06

## Objective
Upgrade the Native Scanner to use the "Full Potential" of Zigler without losing Windows stability.

## Steps Taken

### 1. Library Grafting
Zig doesn't allow `@import` from outside the project directory. We copied the Zigler BEAM bridge into our source:
- `native/scanner/src/beam/`

### 2. Platform Patching
Zigler's internal `erl_nif.zig` expects `erl_nif_win.h` on Windows. We updated it to use the standard `erl_nif.h` which is always available via our Erlang include path.

### 3. Logic Refactor
We replaced the manual `WinNifApi` struct usage with Zigler's `beam` module.
- `scanner_safe.zig` now uses `beam.env` and `beam.term`.
- Asynchronous messaging uses `beam.send`.

### 4. Verification
Executed `mix test test/ether/native/streaming_test.exs`:
```
Received Chunk 1: 15446 bytes
Received Chunk 2: 7447 bytes
Scan Completed Signal Received
.
Finished in 1.4 seconds (0.00s async, 1.4s sync)
1 test, 0 failures
```

## Results
- 100% test pass.
- Minimal boilerplate in Zig.
- Robust C-linkage preserved.
