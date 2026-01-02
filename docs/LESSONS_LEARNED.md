# Aether IDE - Lessons Learned & Problem Log
**Date:** 2026-01-02
**Purpose:** Record all problems encountered during initial development for future reference.

---

## 1. Zig/NIF Compilation Issues (CRITICAL)

### Problem
The project used `Zigler` (Elixir-Zig bridge) for high-performance file scanning. This caused persistent compilation failures on Windows.

### Symptoms
- `std.fs.File.WriteError` - Zig standard library version mismatch
- `zig executable not found` - Path resolution failures
- `public function named 'scan' not found` - Module linking issues
- `Zig.Parser.ParseError: did not expect utf8 codepoint` - Inline Zig code encoding issues

### Root Causes
1. **Version Incompatibility**: System had Zig 0.11/0.16 installed, but `Zigler 0.13.3` requires exactly Zig **0.13.0**.
2. **PATH Conflicts**: Windows system PATH contained the wrong Zig version, which Zigler prioritized over its managed version.
3. **Windows Quirks**: Zigler searched for `zig` (Linux style) instead of `zig.exe` (Windows style).
4. **Build Caching**: Old compilation artifacts in `_build/` persisted incorrect Zig paths even after config changes.

### Status: Failed (Reverted)

### Solution
**Removed Zig entirely. Switched to Pure Elixir stack.**
We prioritized stability over raw performance for the MVP.

---

## 2. Database Configuration Issues

### Problem
`Postgrex.Error: FATAL 28P01 (invalid_password)`

### Status: Success

### Solution
Updated `config/dev.exs` with correct local password.

### Additional Issue
`FATAL 3D000 database "aether_dev" does not exist`

### Status: Success

### Solution
Added `mix ecto.create` to launch script.

---

## 3. NPM/Asset Watcher Issues

### Problem
`Could not start watcher "npm"` - Executable not found  
`(stop) :eacces` - Access denied when trying to run `npm.cmd`

### Status: Success

### Solution
1. Added `C:\Program Files\nodejs` to PATH in `start_dev.bat`.
2. Changed watcher config: `cmd: ["/c", "npm", "run", "dev", cd: ...]`

---

## 4. Phoenix Template/Layout Issues

### Problem
`ArgumentError: no 'app' html template defined for AetherWeb.LayoutView`

### Status: Success

### Solution
Ensured layouts.ex has proper `app/1` function or `app.html.heex` template (but not both!).

---

## 5. PowerShell Execution Policy

### Problem
`mix.ps1 cannot be loaded because running scripts is disabled on this system`

### Status: Success

### Solution
Use `cmd.exe` or `.bat` scripts instead of PowerShell.

---

## 6. livebook Dependency

### Problem
`FunctionClauseError` during compilation.

### Status: Success

### Solution
Removed `livebook` from `mix.exs`. Not critical for MVP.

---

## 7. Phoenix LiveView 1.0 Changes

### Problem
`The task "compile.phoenix_live_view" could not be found`

### Status: Success

### Solution
Removed `:phoenix_live_view` from `compilers` in `mix.exs`.

---

## Summary: The Pure Elixir Stack (SPEL-AI)

1. **NO NIFs** - Use pure Elixir for all logic.
2. **Svelte 5 Runes** - `$state`, `$derived`, `$effect` for frontend.
3. **Instructor-First** - Structured LLM outputs via Ecto schemas.
4. **One Runtime** - Only Erlang/Elixir required.

---

## 8. Zigler 0.15.2 on Windows (Header Missing)

### Problem
`C import failed: erl_nif_win.h file not found`

### Context
Attempted to re-integrate Zig using Zigler 0.15.2. Compilation of NIFs failed specifically on Windows because the required Erlang NIF header file for Windows was not found in the expected include path within the `_build` directory.

### Status: Failed (Safe Mode Active)

### Solution
**Reverted to Pure Elixir**. 
While the "Unbreakable Zig Protocol" (local binary management) solved the PATH and Version issues, the internal tooling of Zigler 0.15.x seems to have a regression or configuration gap for Windows headers. We prioritized stability over raw performance for the `Scanner` module.

---

## 9. Dependency Conflict: Jido vs Credo

### Problem
`Mix` failed to resolve dependencies:
```
deps/ex_dbug/mix.exs: {:credo, ..., optional: false}
mix.exs: {:credo, ..., only: [:dev, :test]}
```

### Root Cause
The `jido` library pulls in `ex_dbug`, which requires `credo` as a runtime dependency (not optional). However, our root project defined `credo` as `only: [:dev, :test]`. Elixir's dependency resolution forbids a transitive dependency from being "more available" than the root definition allows.

### Status: Success

### Solution
Removed `only: [:dev, :test]` from the `credo` definition in `mix.exs`, making it available in all environments. This satisfied `ex_dbug`'s requirement.

---

## 10. The Resilient Bridge Pattern

### Problem
Native dependencies (NIFs) introduce a risk of crashing the entire VM or failing to compile on certain environments (e.g., missing C headers on Windows).

### Status: Success

### Solution
Implement a **Bridge Module** (`Aether.Native.Bridge`) that:
1. Wraps the NIF call in a `try/rescue/catch` block.
2. Checks for module availability (`Code.ensure_loaded?`).
3. specificially handles `{:error, :native_disabled}` or similar flags.
4. Seamlessly degrades to a Pure Elixir implementation (The Fallback) if the Native path fails.

This ensures the application is "Unbreakable" regardless of the underlying environment's readiness for native compilation.
