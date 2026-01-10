# Debugging Journey: Aether IDE Startup Issues
**Date:** 2026-01-04  
**Duration:** ~2 hours  
**Outcome:** Successfully resolved all issues, File Explorer now displays files

---

## The Problem

When launching Aether IDE, the application showed a **"Forever Spinning"** loader. The File Explorer never populated with files, and the user couldn't determine if this was a frontend, backend, or configuration issue.

---

## Part 1: Initial Symptom - "Forever Spinning" App Loader

### What We Saw
- The app launched but showed only a loading spinner
- No files appeared in the File Explorer
- No visible error messages in the UI

### Why It Happened
The "shell-first" architecture was designed to show the UI immediately while data loads in the background. However, multiple underlying issues prevented the data from ever arriving.

### Lesson Learned
**A spinning loader with no errors means something is silently failing.** The lack of error messages doesn't mean there are no errors - it means errors are being swallowed somewhere in the stack.

---

## Part 2: Backend Syntax Error - Trailing Comma

### What We Found
In `config/dev.exs`, there was a trailing comma after the `secret_key_base` configuration:

```elixir
# BROKEN
secret_key_base: "xxx",  # <-- Trailing comma, no next item!
```

### Why It Broke Things
Elixir's keyword list syntax requires items after a comma. The trailing comma caused a **compile-time syntax error**, preventing the entire backend from starting.

### The Fix
```elixir
# FIXED
secret_key_base: "xxx"  # No trailing comma
```

### Lesson Learned
**Always check backend compilation first.** Run `mix compile` to catch syntax errors before investigating complex issues. A single misplaced character can break everything.

---

## Part 3: Tauri Configuration Issues

### What We Found
In `src-tauri/tauri.conf.json`:
1. `beforeDevCommand` was using `npm` instead of `bun`
2. The `cwd` (current working directory) was wrong
3. `devUrl` was pointing to Phoenix (4000) instead of Vite (5173)

### Original (Broken)
```json
{
  "beforeDevCommand": "npm run dev",
  "devUrl": "http://localhost:4000"
}
```

### Fixed
```json
{
  "beforeDevCommand": "bun run --cwd assets dev",
  "devUrl": "http://localhost:5173"
}
```

### Why It Matters
- Tauri needs to know WHERE to run the dev command (`cwd`)
- Tauri needs to know WHAT URL to load (`devUrl`)
- Using the wrong package manager (`npm` vs `bun`) can fail silently

### Lesson Learned
**Check your build tool chain configuration.** When you have multiple build systems (Tauri + Vite + Phoenix), each needs to be configured correctly to talk to the others.

---

## Part 4: Missing CSS Framework - DaisyUI

### What We Found
The UI appeared unstyled/broken because `@plugin "daisyui";` was missing from `assets/src/app.css`.

### Why It Happened
At some point, the DaisyUI plugin directive was removed or commented out, causing all Tailwind+DaisyUI classes to have no effect.

### The Fix
```css
/* assets/src/app.css */
@import "tailwindcss";
@plugin "daisyui";  /* <-- This was missing */
```

### Lesson Learned
**CSS frameworks need to be explicitly loaded.** Unlike some frameworks that auto-detect plugins, Tailwind 4 with DaisyUI requires the `@plugin` directive.

---

## Part 5: Backend Not Starting - PowerShell & Port Conflicts

### What We Found
Two issues:
1. **PowerShell Execution Policy**: Running `mix phx.server` in PowerShell failed with `UnauthorizedAccess` because scripts were blocked
2. **Port Conflict (`:eaddrinuse`)**: A zombie Erlang process was holding port 4000

### The Errors
```
mix : File ... cannot be loaded because running scripts is disabled
```
```
** (EXIT) :eaddrinuse
```

### The Fixes
1. Use `cmd /c mix phx.server` to bypass PowerShell restrictions
2. Kill zombie processes: `taskkill /F /IM beam.smp.exe`

### Lesson Learned
**Windows has unique challenges.** PowerShell execution policies and zombie processes are common Windows issues. Always use `cmd /c` for Elixir commands on Windows, and check for port conflicts when seeing `:eaddrinuse`.

---

## Part 6: Database Dependency

### What We Found
The backend was trying to connect to PostgreSQL on startup. When the database wasn't available, the entire application crashed.

### The Problem
In `lib/aether/application.ex`:
```elixir
children = [
  Aether.Repo,  # <-- This requires PostgreSQL
  ...
]
```

### The Fix
Comment out the database dependency since it wasn't needed for the File Explorer:
```elixir
children = [
  # Aether.Repo,  # Disabled - not needed for file operations
  ...
]
```

Also removed `Phoenix.Ecto.CheckRepoStatus` from `endpoint.ex`.

### Lesson Learned
**Not all features need all dependencies.** If you're working on a feature that doesn't need the database, disable the database to reduce failure points.

---

## Part 7: WebSocket Connection Failures

### What We Saw
```
WebSocket connection to 'ws://localhost:5173/socket/...' failed
```

### Why It Happened
The frontend was connecting to Vite's dev server (5173), expecting Vite to proxy the WebSocket to Phoenix (4000). But the proxy wasn't working correctly.

### The Fix
Changed the socket URL from relative to absolute:

```javascript
// Before (relies on proxy)
const socket = new Socket("/socket", {...})

// After (direct connection)
const socket = new Socket("ws://localhost:4000/socket", {...})
```

### Lesson Learned
**WebSocket proxies are fragile.** When debugging connection issues, try bypassing the proxy with a direct connection first. This eliminates one variable from the equation.

---

## Part 8: NIF Scanner "Silent Failure"

### What We Thought
The Zig NIF scanner wasn't sending any file data because the backend showed:
```
[info] CH: Scan Completed in 0ms
```

### What We Investigated
- Added logging to `EditorChannel.handle_info({:binary, ...})`
- Checked if `Aether.Scanner.scan_raw` was being called
- Verified the NIF was compiled (`scanner.dll` exists)

### What We Found
After adding logging:
```
[info] CH: Received binary chunk of 383 bytes
```

The NIF **WAS** sending data! The problem was elsewhere.

### Lesson Learned
**Add logging at every layer.** When debugging data flow, add logs at each step: Frontend → Channel → Scanner → NIF → Scanner → Channel → Frontend. The log that's missing tells you where the break is.

---

## Part 9: Frontend Event Tracing

### What We Added
Console logs to trace event reception:
```javascript
ch.on("filetree:chunk", (payload) => {
  console.log("Received filetree:chunk!", payload);
  const newFiles = NifDecoder.decodeChunk(payload.chunk, ".");
  console.log("Decoded", newFiles.length, "files:", newFiles);
});
```

### What We Saw
```
Received filetree:chunk! {chunk: '...'}
Decoded 31 files: [...]
Received filetree:done! Flushing batch...
```

### What This Told Us
The frontend was receiving AND decoding the data correctly. 31 files were decoded. But they weren't showing up in the UI.

### Lesson Learned
**Trace data through the entire pipeline.** Just because data enters a system doesn't mean it exits correctly. Follow it all the way to the final render.

---

## Part 10: The Final Bug - Prop Name Mismatch

### The Root Cause
In `SideBar.svelte`:
```svelte
<FileExplorer {fileTree} ... />
```

In `FileExplorer.svelte`:
```svelte
let { files = [] } = $props();
```

**The prop was named `fileTree` but the component expected `files`!**

### The Fix
```svelte
<FileExplorer files={fileTree} ... />
```

### Why It Was Hard to Find
1. No compile-time error (Svelte 5 doesn't enforce prop names)
2. No runtime error (undefined prop just uses default `[]`)
3. The component rendered fine (just with an empty array)

### Lesson Learned
**Prop mismatches are silent killers.** When a component receives data but doesn't display it, check:
1. Is the prop name correct?
2. Is the data format correct?
3. Is there a default value hiding the error?

---

## Summary: The Debugging Methodology

### 1. Start from the Outside
We began by checking if the backend was even running (it wasn't).

### 2. Check Each Layer Independently
- Backend: `mix compile`, `mix phx.server`
- Frontend: `bun run build`, browser console
- Connection: WebSocket status, channel join logs

### 3. Add Logging at Boundaries
- Channel receive: `Logger.info("Received...")`
- Frontend events: `console.log("Received...")`

### 4. Follow the Data
```
User clicks refresh
  → Frontend sends "filetree:list_raw"
    → Channel calls Scanner.scan_raw
      → NIF scans directory
      → NIF sends {:binary, chunk}
    → Channel encodes and pushes "filetree:chunk"
  → Frontend receives chunk
    → NifDecoder parses binary
    → Files added to fileTree state
  → SideBar passes to FileExplorer
    → FileExplorer renders files  ← BREAK WAS HERE
```

### 5. Question Your Assumptions
The hardest bugs are where you assume something is correct. We assumed the prop passing was correct because "I wrote that code and it looks right."

---

## Prevention: What We Created

1. **`check_env.bat`** - Verify all tools are installed
2. **`verify_setup.bat`** - Test all project components
3. **`docs/REQUIRED_VERSIONS.md`** - Document exact versions needed

These scripts will catch most issues BEFORE you spend hours debugging.

---

## Success Verification: The Working System

After fixing all 10 issues **one at a time**, the console finally showed:

```
App.svelte:47 App Mounted. Socket: Socket
App.svelte:51 Attempting to join channel...
App.svelte:58 Joined EditorChannel Object
App.svelte:47 App Mounted. Socket: Socket
App.svelte:128 Firing filetree:list_raw request...
App.svelte:131 list_raw OK: Object
App.svelte:91 Received filetree:chunk! Object
App.svelte:94 Decoded 33 files: Array(33)
App.svelte:104 Received filetree:done! Flushing batch...
```

**This is what success looks like:**
1. ✅ Socket connected
2. ✅ Channel joined
3. ✅ File list requested
4. ✅ Server responded OK
5. ✅ Chunk received
6. ✅ Files decoded (33 files!)
7. ✅ Batch flushed to UI
8. ✅ **File Explorer displays files!**

---

## The Step-by-Step Approach

We solved these problems **one at a time**, not all at once:

1. **Fix one thing** → Test → Still broken?
2. **Fix next thing** → Test → Still broken?
3. **Repeat until working**

This is crucial because:
- Each fix revealed the NEXT problem
- If we tried to fix everything at once, we wouldn't know which fix actually helped
- Some "fixes" might have been wrong and we'd need to undo them

**Example progression:**
```
[Start] Forever spinner, no errors
   ↓ Fix trailing comma
[Test] Backend now compiles! But... still spinning
   ↓ Fix Tauri config
[Test] Frontend builds! But... still spinning
   ↓ Fix DaisyUI
[Test] UI styled! But... still spinning
   ↓ Fix PowerShell/port
[Test] Backend runs! But... connection refused
   ↓ Fix database dependency
[Test] Backend stable! But... WebSocket fails
   ↓ Fix direct WebSocket
[Test] Connected! But... no files
   ↓ Add logging
[Test] Chunks received! But... UI empty
   ↓ Fix prop mismatch
[SUCCESS] Files visible! 🎉
```

---

## Final Thoughts

This debugging session touched every layer of the stack:
- Elixir configuration
- Phoenix channels
- Zig NIFs
- Svelte 5 components
- Tauri desktop wrapper
- Vite build system
- Windows environment

The key insight: **Complex systems fail in complex ways.** A single trailing comma created a cascade of symptoms that looked like WebSocket failures, NIF bugs, and UI rendering problems. Always start simple and work outward.
