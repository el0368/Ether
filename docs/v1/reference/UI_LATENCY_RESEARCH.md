# Research: UI Latency Analysis

**Date**: 2026-01-09
**Status**: Investigation In Progress

## User Observations

1. Switching between Activity Bar icons is not instant.
2. Opening a folder takes time to show files.
3. Window minimize/maximize sometimes feels inconsistent.
4. "Something is secretly working behind the scenes."

---

## Potential Latency Sources Identified

### 1. Background Scan Task (High Priority)

**File**: `lib/ether/native/scanner.ex`

The scanner runs in a `Task.start/1` but sends messages back to the LiveView:

```elixir
Task.start(fn ->
  {:ok, resource} = create_context_nif(ignores)
  case do_scan_loop(resource, path, caller, depth_limit) do
    ...
  end
end)
```

**Problem**: The scan loop is yieldable but may still block the scheduler if the project is large. Additionally, the `do_scan_loop/4` function is recursive and may generate thousands of messages rapidly.

**Impact**: High CPU usage during scans, which can affect *all* LiveView interactions (clicks, updates).

---

### 2. Stream Flush Interval (Medium Priority)

**File**: `lib/ether_web/live/workbench_live.ex`

```elixir
@flush_interval_ms 100
```

The scan buffer is flushed every 100ms, processing up to 500 items per flush:

```elixir
{to_stream, remaining} = Enum.split(all_items, 500)
```

**Problem**: 
- 100ms is frequent; combined with 500 items, this can cause significant redraws.
- If the buffer fills faster than it's flushed, the UI becomes choppy.

**Potential Fix**: Increase flush interval or reduce batch size.

---

### 3. File Watcher Subscription (Low Priority)

**File**: `lib/ether/watcher.ex`

The watcher is *not* started in `application.ex`, so this is currently inactive. However, if it were started, it could emit rapid `:file_delta` events during scans.

**Status**: Not a current issue.

---

### 4. CSS Transitions (Low Priority)

**File**: `lib/ether_web/components/workbench/activity_bar.ex`

```elixir
class={"... transition-colors duration-200 ..."}
```

**Problem**: `transition-colors duration-200` causes a 200ms animation. This is intentional for polish, but if combined with other delays, it *feels* slower.

**Potential Fix**: Reduce to 100ms or 50ms for perceived speed.

---

### 5. Tauri Window Frame Handling (Medium Priority)

Minimize/maximize delay may be related to Tauri's interop between the Rust shell and the WebView.

**Action**: Check if the issue persists with a pure web browser (not Tauri).

---

## Recommended Next Steps

1. **Reduce Flush Interval**: Change `@flush_interval_ms` from 100 to 50.
2. **Reduce Batch Size**: Change from 500 to 200 items per flush.
3. **Speed Up Transitions**: Reduce CSS transition duration.
4. **Profile with Telemetry**: Add `Telemetry` spans around key operations.
5. **Test in Browser**: Verify if lag is LiveView-related or Tauri-related.

---

## Conclusion

The likely cause is the combination of:
- Aggressive scan buffering (100ms, 500 items)
- CSS transitions (200ms)
- Server-side processing during scans

None of these are true "background threads secretly working," but running a file scan *does* cause system load that affects UI responsiveness.

---
*Author: Antigravity Agent*
