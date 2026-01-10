# Diagnosis: UI Latency & Application Freezes

**Date**: 2026-01-09
**Status**: Root Cause Identified (Level 4 Confidence)

## 🚨 Executive Summary

The "Visual Delay" and "App Freezes" are caused by a **Main Thread Congestion** (Packet Storm) issue, primarily driven by the **File Scanner's aggressive flush rate** combined with **Client-Side DOM Thrashing**.

1.  **Visual Delay**: Caused by the browser's Main Thread being saturated by `morphdom` patches (200 items every 50ms), delaying the handling of `click` events.
2.  **App Freeze**: The **Custom Window Controls** are JavaScript-driven (`window_controls.js`). When the Main Thread is locked by a particularly large DOM update (e.g., initial render of a folder with 2,000 files), these controls become unresponsive because their Event Listeners cannot execute.

---

## 🔍 Root Cause Analysis

### 1. The "Packet Storm" (Source of Usage Spike)
**Location**: `lib/ether_web/live/workbench_live.ex`

```elixir
@flush_interval_ms 50  # TOO FAST
...
{to_stream, remaining} = Enum.split(all_items, 200) # TOO LARGE
```

*   **Mechanism**: The backend pushes ~200 file nodes to the frontend every 50ms.
*   **Result**: The frontend receives ~20 updates per second. Each update inserts 200 DOM nodes.
*   **Throughput**: 4,000 DOM nodes/second. Browser layout engines cannot sustain this without dropping frames, leading to "jank" and input lag.

### 2. The Window Control Deadlock
**Location**: `assets/js/hooks/window_controls.js`

```javascript
this.el.addEventListener("click", async e => { ... })
```

*   **Mechanism**: These are **Standard DOM Event Listeners**. They run on the same thread as the UI rendering.
*   **The Freeze**: If the Main Thread is busy calculating the layout for 200 new file rows (which takes 20-100ms on complex trees), it **blocks** the processing of the click event on the Close button. The user clicks, nothing happens (Main Thread busy), and the OS thinks the window is unresponsive if this persists for >2 seconds.

### 3. NIF Resource Starvation (Secondary)
**Location**: `Ether.Scanner.scan_async`

While the recursive scan itself is fast, if it floods the message box of the LiveView process, the LiveView becomes a bottleneck, processing `handle_info` loops instead of handling `handle_event` (clicks). This contributes to the **Visual Delay** (clicking a file doesn't highlight it immediately).

---

## 🛠️ Recommendations

To restore "Native-Like" responsiveness, we must perform **Traffic Shaping**:

1.  **Throttle the Firehose**:
    *   Change `@flush_interval_ms` from `50` to `200` (5fps is sufficient for file loading).
    *   Reduce batch size from `200` to `100`.

2.  **Prioritize User Interaction**:
    *   Ensure NIF callbacks yield to the scheduler/liveview to allow `handle_event` (clicks) to interleave with `handle_info` (scan results).

3.  **Move Window Controls to Native (Optional)**:
    *   Ideally, use Tauri's native titlebar config if possible, but for custom UI, ensuring the Main Thread is free is the only fix.

## ✅ Verification Strategy

1.  Increase flush interval to 200ms.
2.  Observe CPU usage drops in Chrome DevTools "Performance" tab.
3.  Click "Minimize" during a scan to verify responsiveness.
