# Aether IDE - Lessons Learned & Problem Log
**Date:** 2026-01-01
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

### Final Resolution
**Removed Zig entirely. Switched to Pure Elixir stack.**

---

## 2. Database Configuration Issues

### Problem
`Postgrex.Error: FATAL 28P01 (invalid_password)`

### Resolution
Updated `config/dev.exs` with correct local password.

### Additional Issue
`FATAL 3D000 database "aether_dev" does not exist`

### Resolution
Added `mix ecto.create` to launch script.

---

## 3. NPM/Asset Watcher Issues

### Problem
`Could not start watcher "npm"` - Executable not found  
`(stop) :eacces` - Access denied when trying to run `npm.cmd`

### Resolution
1. Added `C:\Program Files\nodejs` to PATH in `start_dev.bat`.
2. Changed watcher config: `cmd: ["/c", "npm", "run", "dev", cd: ...]`

---

## 4. Phoenix Template/Layout Issues

### Problem
`ArgumentError: no 'app' html template defined for AetherWeb.LayoutView`

### Resolution
Ensured layouts.ex has proper `app/1` function or `app.html.heex` template (but not both!).

---

## 5. PowerShell Execution Policy

### Problem
`mix.ps1 cannot be loaded because running scripts is disabled on this system`

### Resolution
Use `cmd.exe` or `.bat` scripts instead of PowerShell.

---

## 6. livebook Dependency

### Problem
`FunctionClauseError` during compilation.

### Resolution
Removed `livebook` from `mix.exs`. Not critical for MVP.

---

## 7. Phoenix LiveView 1.0 Changes

### Problem
`The task "compile.phoenix_live_view" could not be found`

### Resolution
Removed `:phoenix_live_view` from `compilers` in `mix.exs`.

---

## Summary: The Pure Elixir Stack (SPEL-AI)

1. **NO NIFs** - Use pure Elixir for all logic.
2. **Svelte 5 Runes** - `$state`, `$derived`, `$effect` for frontend.
3. **Instructor-First** - Structured LLM outputs via Ecto schemas.
4. **One Runtime** - Only Erlang/Elixir required.
