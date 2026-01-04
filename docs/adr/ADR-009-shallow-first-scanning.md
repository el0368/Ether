# ADR-009: Shallow-First Scanning & Lazy Expansion

## Context
Diagnosis of the "Antigravity" storage engine (2026-01-04) revealed that the Zig NIF scanner achieves sub-second performance by performing a **Shallow Scan** (Depth-2). It iterates the root directory and immediate subdirectories but does not recurse deeper. This prevents the "Event Loop Starvation" that occurred with deep recursive Elixir scans but results in "missing" file data for deep directory structures.

## Decision
We formally adopt **Shallow-First Scanning** as the primary strategy for Aether's file system interaction.

1.  **Initial Scan:** The backend will perform a shallow scan (Depth-2) on startup. This ensures the "Shell-First" UI populates instantly (< 800ms).
2.  **Lazy Expansion:** Deep directory contents will be fetched **On-Demand**.
    *   When a user expands a directory in the File Explorer, the frontend will issue a `scan_subdir(path)` request.
    *   The Zig NIF will scan strictly that target directory (and its immediate children, maintaining the Depth-2 pattern locally) and stream the results.
3.  **Frontend State:** The Svelte 5 store must handle dynamic insertion of file nodes into the active `fileTree` upon receiving these on-demand chunks.

## Consequences
### Positive
*   ✅ **Startup Speed:** Maintains the < 2s startup metric regardless of project size (e.g., monorepos).
*   ✅ **Memory Efficiency:** avoiding loading the entire file tree (potentially 100k+ nodes) into memory/JSON implementation atoms on launch.
*   ✅ **Responsiveness:** The UI remains interactive as data is loaded in small, manageable chunks.

### Negative
*   🟡 **Search Complexity:** "Go to File" (Ctrl+P) will only find *loaded* files. We may need a separate "Background Indexer" (Search Agent) for full-text search capability.
*   🟡 **State Complexity:** The frontend requires robust logic to patch the flat or tree data structure accurately without causing jitter or duplication.

## Status
Accepted
