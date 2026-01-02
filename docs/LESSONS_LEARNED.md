**Date:** 2026-01-02
**Status:** Hybrid Ignition Attempt 3 Failed. Reverted to Safe Mode.

---

## 🛠️ The Windows "Build Tax" & Native Ignition (Session 4)

### 11. The "Ghost Header" Mystery (erl_nif_win.h)
**Problem:** Zigler compilation failed with `erl_nif_win.h not found`.
**Discovery:** Modern Erlang (OTP 25+) consolidated logic, removing this file. Zigler still expects it.
**Solution:** Manually created shim header `#include "erl_nif.h"`.
**Outcome:** Reduced errors from 2 to 1.
**Critical Failure:** `cimport.zig:3244:80: error: no field named 'NAME' in struct 'cimport.TWinDynNifCallbacks'`.
**Meaning:** Zig's C-translator failed to parse the `WinDynNifCallbacks` struct logic in `erl_nif.h` (OTP 27 AND OTP 26), likely due to macro complexity or `erl_nif_api_funcs.h` inclusion order. This is a fundamental ABI/Tooling mismatch.

### 12-B. The Elixir Version Lock (Final Attempt)
**Action:** Re-aligned stack to Elixir 1.19 (OTP 26) + Erlang 26 (erts-14.2) + Zigler 0.15.2.
**Outcome:** **Failed** with the exact same `TWinDynNifCallbacks` error.
**Conclusion:** Zigler 0.15.2 is fundamentally incompatible with Windows Erlang Headers (25/26/27/28) due to macro parsing issues in `translate-c`. Native Windows dev is blocked.

### 13. Dependency Hell & NMake
**Problem:** Missing `nmake` prevented native builds.
**Solution:** Updated `start_dev.bat` to source `VsDevCmd.bat`.
**Outcome:** Successfully loaded build tools, but Zigler build still failed with generic "native errors".

### 13. The "Self-Healing" Terminal Strategy
**Problem:** Missing dev environment variables.
**Solution:** `start_dev.bat` auto-detects missing tools and repairs the PATH.
**Status:** **SUCCESS**. This script pattern works perfectly and should be standard.

---

## 🧠 Architectural Philosophy (Session 3-4)

### 14. The "Resilient Hybrid" Pattern
**Problem:** Persistent native build failures on Windows.
**Solution:** The "Unbreakable" strategy dictates that if Native Ignition fails, we **Safe Mode** the project.
*   **Disabled:** Zigler dependency & Native Scanner.
*   **Active:** `Aether.Native.Bridge` falling back to Elixir.
**Insight:** We spent significant effort (Ghost Header, NMake) trying to force the engine to start. While the *environment* is now fixed, the library compatibility (Zigler vs Windows ABI) remains a blocker. The responsible engineering decision is to accept the Fallback.
