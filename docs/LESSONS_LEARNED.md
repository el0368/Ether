# 📚 Aether: Lessons Learned & Technical Journal

This document records the engineering hurdles and "Flawless" solutions discovered during the development of Aether.

**Date:** 2026-01-02
**Status:** Hybrid Ignition Verified via Ghost Header Shim.

---

## 🛠️ The Windows "Build Tax" & Native Ignition (Session 4)

### 11. The "Ghost Header" Mystery (erl_nif_win.h)
**Problem:** Zigler/Zig compilation failed with `erl_nif_win.h not found`, even after reinstalling Erlang and confirming `erl_nif.h` was present.
**Discovery:** Modern Erlang (OTP 25+) consolidated its Windows dynamic linking logic into `erl_nif.h` and `erl_nif_api_funcs.h`. The standalone `erl_nif_win.h` file no longer exists in standard installations. However, Zigler (and the Zig C-import system) still searches for that specific filename to trigger the `TWinDynNifCallbacks` logic required for Windows DLLs to talk to the BEAM.
**Lesson:** When a bridge (Zigler) hasn't caught up to the platform (OTP), create a Compatibility Shim.
**Solution:** Manually create `erl_nif_win.h` in the Erlang include folder containing only `#include "erl_nif.h"`. This satisfies the file-check while using the modern, correct code.

### 12. Dependency Hell (nmake & 0x80070666)
**Problem:** Dependencies like `jaxon` failed to compile due to missing `nmake`. VC++ Redistributable failed with `0x80070666`.
**Discovery:** 
* `nmake` is part of the Visual Studio Build Tools, not the basic runtime.
* Error `0x80070666` means a newer runtime is already present; the requirement is already met.
**Lesson:** Always launch development from a Developer Command Prompt to ensure `nmake` and C++ headers are in the environment PATH.

### 13. The "Self-Healing" Terminal Strategy
**Problem:** Developers forget to open the special "Developer Command Prompt," leading to obscure build failures (`nmake` not found).
**Solution:** Embedded environment detection in `start_dev.bat`.
* Checks if `nmake` is in PATH.
* If missing, automatically sources `VsDevCmd.bat`.
**Result:** The project "upgrades" the shell automatically. 0-click setup for the user.

---

## 🧠 Architectural Philosophy (Session 3-4)

### 14. The "Resilient Hybrid" Pattern
**Problem:** Native code is "fragile" on Windows due to environment variations.
**Solution:** We moved from "Hard Requirement" Zig to Supervised Reflexes.
* **The Brain (Elixir):** Wraps native calls in try/rescue/catch.
* **The Fallback:** If Zig fails or isn't compiled, the system transparently falls back to the Pure Elixir scanner.
**Insight:** A "Flawless" system isn't one that never fails; it's one that handles failure so gracefully the user never notices.

### 15. Hermetic Tooling (Local Zig)
**Problem:** System-wide Zig versions (0.13 vs 0.15) caused build breaks.
**Solution:** Enabled `local_zig: true` in `config.exs` and used `mix zig.get`.
**Lesson:** An industrial project must carry its own tools. Pinning Zig 0.15.0 inside `_build` ensures portability.

### 16. Invisible Failures (Observability)
**Problem:** In production, terminal logs are invisible. Fallbacks must be communicated to the user.
**Solution:** Implemented UI Telemetry. The Bridge broadcasts an `:engine_status` event via Phoenix PubSub.
**Result:** The UI shows a "High Performance" indicator, making the integration Unquestionably Visible.

---

## 📜 Historical Logs (Session 1-3)

### 1. Zig/NIF Compilation Issues (Initial Attempt)
**Problem:** The project used `Zigler` (Elixir-Zig bridge) for high-performance file scanning. This caused persistent compilation failures on Windows.
**Symptoms:** `std.fs.File.WriteError`, `zig executable not found`, `public function named 'scan' not found`.
**Root Causes:**
1. Version Incompatibility (Zig 0.11/0.16 vs Zigler 0.13.3).
2. PATH Conflicts.
3. Windows Quirks (zig vs zig.exe).
**Status:** Failed (Reverted to Pure Elixir MVP).
**Solution:** Removed Zig entirely. Switched to Pure Elixir stack to prioritize MVP stability.

### 2. Database Configuration Issues
**Problem:** `Postgrex.Error: FATAL 28P01 (invalid_password)`
**Status:** Success
**Solution:** Updated `config/dev.exs` with correct local password.

### 3. NPM/Asset Watcher Issues
**Problem:** `Could not start watcher "npm"` - Executable not found.
**Status:** Success
**Solution:** Added `C:\Program Files\nodejs` to PATH in `start_dev.bat` and updated watcher config.

### 4. Phoenix Template/Layout Issues
**Problem:** `ArgumentError: no 'app' html template defined for AetherWeb.LayoutView`
**Status:** Success
**Solution:** Ensured layouts.ex has proper `app/1` function or `app.html.heex` template.

### 5. PowerShell Execution Policy
**Problem:** `mix.ps1 cannot be loaded because running scripts is disabled on this system`
**Status:** Success
**Solution:** Use `cmd.exe` or `.bat` scripts instead of PowerShell.

### 6. livebook Dependency
**Problem:** `FunctionClauseError` during compilation.
**Status:** Success
**Solution:** Removed `livebook` from `mix.exs`. Not critical for MVP.

### 7. Phoenix LiveView 1.0 Changes
**Problem:** `The task "compile.phoenix_live_view" could not be found`
**Status:** Success
**Solution:** Removed `:phoenix_live_view` from `compilers` in `mix.exs`.

### 8. Zigler 0.15.2 on Windows (Header Missing)
**Problem:** `C import failed: erl_nif_win.h file not found` during Session 3 re-integration.
**Status:** Failed (At the time)
**Solution:** Reverted to Pure Elixir (Safe Mode) temporarily. *Later resolved by Lesson #11 (Ghost Header).*

### 9. Dependency Conflict: Jido vs Credo
**Problem:** `Mix` failed to resolve dependencies due to `credo` being `only: [:dev, :test]` while `jido` required it at runtime.
**Status:** Success
**Solution:** Removed `only: [:dev, :test]` from `credo` in `mix.exs`.

### 10. The Resilient Bridge Pattern (Initial Concept)
**Problem:** Native dependency fragility.
**Status:** Success
**Solution:** Implemented `Aether.Native.Bridge` to wrap NIF calls and fallback to Elixir. *Refined in Lesson #14.*
