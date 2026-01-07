# ADR-021: Stack-Safe Windows NIF Infrastructure

## Context
Erlang's **Dirty Scheduler** threads on Windows have a very limited default stack size (historically ~64KB). Zig's `std.fs` and `std.unicode` functions often use stack buffers for UTF-8 to UTF-16 conversions when interacting with Windows APIs. This results in an immediate **Access Violation (0xc0000005)** or illegal instruction when processing absolute paths in a Windows NIF.

## Findings
- **NO-OP NIF**: Stable (rules out NIF overhead/setup).
- **Non-I/O NIF APIs**: Stable (rules out NIF API versioning).
- **`std.fs.openDir`**: Crashes immediately on absolute paths.
- **`searcher.zig`**: Appeared stable only because it was erroring out on relative paths early, avoiding the actual native I/O. When forced to use absolute paths, it also crashes.

## Strategy: Raw Heap Bypass
To achieve stability on Windows, we must bypass the Zig standard library's stack-allocated abstractions for file operations:

1.  **Heap-Based Path Conversion**: Use `nif_api.alloc` to create a UTF-16 buffer on the heap.
2.  **Native Win32 Calls**: Use `MultiByteToWideChar` (via `extern`) to convert paths without touching the stack.
3.  **Low-Level Handles**: Use `CreateFileW` directly followed by `CloseHandle` to verify file/directory existence.
4.  **Standardizing Resource Lifecycle**: Ensure `ScannerResource` always uses `c_allocator` for thread pools and memory to avoid conflicts with BEAM garbage collection.

## Verification Results (Windows 11)

### Microbenchmarks
- **Context Create/Destroy**: ~460 ops/sec
- **Single File Search**: ~400 ops/sec
- **Current Dir Scan**: ~61 ms (full recursion enabled)

### Load Testing (100 Parallel Workers)
- **Concurrent Scans**: **100/100 OK** (~87 scans/sec)
- **Concurrent Searches**: **100/100 OK** (~1800 searches/sec)
- **Mixed Workload**: **50/50 OK**
- **Sustained Load (30s)**: **Stable** (Zero crashes)

### Summary of Stability
The transition to direct Win32 API calls (`kernel32.dll`) combined with heap-allocated path buffers has completely eliminated the "Access Violation" crashes that plagued the NIF when using `std.fs` on Erlang dirty scheduler threads. The system is now production-ready for Windows environments.

---
*Date: 2026-01-07*
