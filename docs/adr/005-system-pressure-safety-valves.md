# ADR 005: System Pressure & Safety Valves

**Date:** 2026-01-04
**Status:** Accepted
**Context:**
During the rollout of the Zero-Copy Streaming architecture, the application experienced "White Screen" crashes on startup.
Root cause analysis revealed "Startup Congestion": The backend (Benchmark & Scanner) was saturating the CPU and Event Loop before the Frontend (Svelte/Tauri) could hydrate the UI.

**Decision:**
We implement a strict "Lazy Ignition" protocol to manage system pressure.

## 1. The "Lazy Ignition" Rule
- **Frontend Priority**: The UI must be allowed to render its initial frame (Spinner/Skeleton) BEFORE any data-heavy operations begin.
- **Throttling**: The Frontend will wait **800ms** after socket connection before requesting the file list (`filetree:list_raw`).
- **No Early Autostart**: Functionality that consumes significant CPU (e.g., Benchmarks, massive scans) MUST NOT trigger automatically on `channel.join`.

## 2. The "Safety Valve" Mechanism
- **Batching**: The UI must buffer incoming high-frequency events (like 5000+ chunked files) and flush them to the DOM at a controlled rate (e.g., 20fps or 50ms intervals).
- **Stack Safety**: Use loops instead of spread operators (`...`) for large arrays to prevent `Maximum call stack size exceeded`.
- **Error Curtains**: Critical failures during startup should be caught and displayed (even rudimentarily) rather than failing silently to a white screen.

**Consequences:**
- **Positive**: Elimination of startup race conditions. Guaranteed "Dark Mode" boot. Responsive UI even under heavy load.
- **Negative**: Slight artificial delay (800ms) before content appears, but perceived performance is higher due to immediate UI feedback (Spinner).
