# Deep Codebase Audit: Performance & Latency

**Date**: 2026-01-09
**Status**: Critical Design Flaws Identified

## 🚨 Final Verdict: "The Firehose Effect"

The application suffers from a classical **Producer-Consumer Mismatch**.
- **Producer**: The Zig-powered `Scanner.zig` + `Scanner.ex`.
- **Consumer**: The `WorkbenchLive` process + Browser DOM.

The Producer is running **ignited** (unthrottled), while the Consumer is **choking** on the data stream.

---

## 🔍 Detailed Findings

### 1. The NIF Spin Loop (Backend Starvation)
**File**: `lib/ether/native/scanner.ex`

```elixir
defp do_scan_loop(...) do
  case scan_yield_nif(...) do
    {:cont, ^resource} ->
      do_scan_loop(...) # ⚠️ IMMEDIATE RECURSION
```

*   **Mechanism**: The Elixir process running the scan invokes the NIF. The NIF runs for a timeslice (approx 1ms), sends a chunk of data (up to 1000 items), and yields. The Elixir process **immediately** calls it again.
*   **Result**: This creates a tight loop that pumps messages into the LiveView's mailbox as fast as the CPU allows. There is no backpressure. The LiveView's mailbox grows indefinitely during large scans.

### 2. The Chunk Size Mismatch
*   **Zig Producer**: Sends chunks of **1000 items** (or 64KB). (`crawler.zig: L11`)
*   **LiveView Consumer**: Buffers them, then flushes **200 items** every **50ms**. (`workbench_live.ex`)
*   **The Overflow**:
    *   In 1 second, Zig can easily send 10-20 chunks (10,000 - 20,000 items).
    *   In 1 second, LiveView can only render 20 batches of 200 (4,000 items).
    *   **Result**: The LiveView process memory balloons, and the message queue becomes so long that `click` events (which are just other messages in the mailbox) are stuck behind thousands of `scanner_chunk` messages. **This causes the "App Freeze".**

### 3. DOM Thrashing (Frontend Lag)
**File**: `assets/js/hooks/window_controls.js` & `workbench_live.html.heex`

*   **Observation**: The updated diagnosis stands. Updating 200 rows every 50ms locks the JS Main Thread, preventing the `click` handlers in `window_controls.js` from firing.

### 4. Code Hygiene Checks
*   **CSS**: `content-visibility: auto` is used correctly. This is NOT the cause.
*   **JS Hooks**: `monaco.js` and `shortcuts.js` are clean and use debouncing/events correctly.
*   **Supervision**: Clean.

---

## 🛠️ The Fix Plan (Backpressure Protocol)

We need to implement **Demand-Driven Architecture** (GenStage style) or simply **Throttling**.

### Step 1: Throttle the NIF (Quick Fix)
Modify `lib/ether/native/scanner.ex` to sleep briefly between chunks.
```elixir
{:cont, ^resource} ->
  Process.sleep(10) # 10ms pause allows ~100 chunks/sec max
  do_scan_loop(...)
```

### Step 2: Resize the Buffers
*   **Zig**: Reduce `CHUNK_SIZE` to 250 (matches UI batch size better).
*   **LiveView**: Increase flush interval to 100ms.

### Step 3: Yield to Pings
Ensure the `do_scan_loop` checks for a "stop/pause" message from the parent LiveView (optional, but good for cancelling scans).

## ✅ Corrective Actions Summary
1.  **Reduce NIF Chunk Size** in `crawler.zig` (1000 -> 250).
2.  **Add Throttling** in `scanner.ex` (Process.sleep(5) or similar).
3.  **Slow Down UI** in `workbench_live.ex` (50ms -> 100ms).
