# 📚 Aether: Lessons Learned & Technical Journal

This document records the engineering hurdles and "Flawless" solutions discovered during the development of Aether.

## 🛠️ The Windows "Build Tax" & Native Ignition

### 1. The "Ghost Header" Mystery (erl_nif_win.h)
**Problem:** Zigler/Zig compilation failed with `erl_nif_win.h not found`, even after reinstalling Erlang and confirming `erl_nif.h` was present.
**Discovery:** Modern Erlang (OTP 25+) consolidated its Windows dynamic linking logic into `erl_nif.h` and `erl_nif_api_funcs.h`. The standalone `erl_nif_win.h` file no longer exists in standard installations. However, Zigler (and the Zig C-import system) still searches for that specific filename to trigger the `TWinDynNifCallbacks` logic required for Windows DLLs to talk to the BEAM.
**Lesson:** When a bridge (Zigler) hasn't caught up to the platform (OTP), create a Compatibility Shim.
**Solution:** Manually create `erl_nif_win.h` in the Erlang include folder containing only `#include "erl_nif.h"`. This satisfies the file-check while using the modern, correct code.

### 2. Dependency Hell (nmake & 0x80070666)
**Problem:** Dependencies like `jaxon` failed to compile due to missing `nmake`. VC++ Redistributable failed with `0x80070666`.
**Discovery:** 
* `nmake` is part of the Visual Studio Build Tools, not the basic runtime.
* Error `0x80070666` means a newer runtime is already present; the requirement is already met.
**Lesson:** Always launch development from a Developer Command Prompt to ensure `nmake` and C++ headers are in the environment PATH.

## 🧠 Architectural Philosophy

### 3. The "Resilient Hybrid" Pattern
**Problem:** Native code is "fragile" on Windows due to environment variations.
**Solution:** We moved from "Hard Requirement" Zig to Supervised Reflexes.
* **The Brain (Elixir):** Wraps native calls in try/rescue/catch.
* **The Fallback:** If Zig fails or isn't compiled, the system transparently falls back to the Pure Elixir scanner.
**Insight:** A "Flawless" system isn't one that never fails; it's one that handles failure so gracefully the user never notices.

### 4. Hermetic Tooling (Local Zig)
**Problem:** System-wide Zig versions (0.13 vs 0.15) caused build breaks.
**Solution:** Enabled `local_zig: true` in `config.exs` and used `mix zig.get`.
**Lesson:** An industrial project must carry its own tools. Pinning Zig 0.15.0 inside `_build` ensures portability.

## 🚀 Observability & Production

### 5. Invisible Failures
**Problem:** In production, terminal logs are invisible. Fallbacks must be communicated to the user.
**Solution:** Implemented UI Telemetry. The Bridge broadcasts an `:engine_status` event via Phoenix PubSub.
**Result:** The UI shows a "High Performance" indicator, making the integration Unquestionably Visible.

---
**Last Updated:** Jan 02, 2026
**Status:** Hybrid Ignition Verified via Ghost Header Shim.
