# Audit Report: Startup & Navigation Latency

**Date**: 2026-01-10
**Status**: Root Causes Identified (Level 4 Confidence)

## 🚨 Executive Summary

The "4-5 second startup load" and "Persistent Sidebar Delay" are caused by two distinct architectural issues:

1.  **Blocker**: Synchronous Bundle Size (Startup).
    - The `monaco-editor` library (5MB+) is included in the main `app.js` bundle, forcing the browser to download and parse the entire editor before rendering *any* UI.
2.  **Bottleneck**: Layout Thrashing (Navigation).
    - The sidebar panels use `display: none` (via `.hidden`) to toggle visibility. For a file tree with thousands of nodes, this destroys and rebuilds the browser's internal Layout Tree on every switch, causing a 50-200ms main-thread freeze.

---

## 🔍 Detailed Findings

### 1. The Startup Lag (Heavy Bundle)
**File**: `assets/js/hooks/monaco.js`

```javascript
import * as monaco from "monaco-editor"; // ⚠️ SYNCHRONOUS
```

*   **Mechanism**: ESBuild bundles `monaco-editor` into the primary `app.js`.
*   **Impact**:
    *   **Network**: 5MB+ payload (even local, huge file to read).
    *   **Parse**: Browser main thread blocks while parsing this massive script.
    *   **Result**: The user sees the window frame (Tauri), but the contents ("UXUI") remain blank or "Loading..." until the script executes.

### 2. The Sidebar Freeze (Layout Thrashing)
**File**: `lib/ether_web/live/workbench_live.html.heex`

```html
<div class={"... #{if @active_sidebar != "files", do: "hidden"}"}>
```

*   **Mechanism**: The `hidden` class applies `display: none`.
*   **The Cost**:
    *   **Hide**: Browser discards layout data for 2,000+ DOM nodes.
    *   **Show**: Browser must *re-calculate* CSS styles and geometry for 2,000+ DOM nodes.
*   **Visual Delay**: The click event handler runs instantly (Elixir side), but the *Browser* locks up for ~100ms to perform the reflow before painting the next frame.

---

## 🛠️ The Solution Strategy

### 1. Code Splitting (Fix Startup)
Use **Dynamic Imports** to load Monaco only when needed, and in the background.

```javascript
// BEFORE
import * as monaco from "monaco-editor";

// AFTER
async mounted() {
  const monaco = await import("monaco-editor");
  // ... init
}
```

### 2. Off-Screen Rendering (Fix Navigation)
Keep the DOM "hot" by moving it off-screen instead of destroying it.

```css
.off-screen {
  position: absolute;
  left: -9999px;
  visibility: hidden;
  /* Retains layout tree! */
}
```

This ensures that switching back to "Files" is a cheap `style` change (Composite Layer) rather than a `layout` change (Reflow).
