# Test Coverage Report

## 1. Backend Logic (Pure Elixir)
**Command**: `cmd /c "mix test"`
**Scope**: Unit tests for Agents, Channels, and core Logic.
**Count**: ~7 Tests (Growing).

### Key Modules Tested
-   `AetherWeb.EditorChannel`
-   `Aether.Agents.FileServerAgent`
-   `Aether.Agents.LSPAgent`

## 2. Native Core (Zig NIF)
**Command**: `scripts/verify_unicode.bat`
**Scope**: Integration/Safety tests for the NIF.
**Coverage**:
-   ✅ NIF Loading/Binding
-   ✅ Unicode Paths (`🚀`) inside Zig `std.fs`
-   ✅ Memory Safety (Allocation/Deallocation)

## 3. Application Integration
**Command**: `scripts/verify_app.bat`
**Scope**: End-to-End checks ensuring the Elixir App successfully calls the NIF.
**Coverage**:
-   ✅ `Aether.Scanner` -> `Aether.Native.Scanner` delegation.

## 4. Frontend (Svelte)
**Command**: N/A (Manual)
**Scope**: UI Interactions.
**Status**: 0 Automated tests. Manual verification requires `start_desktop.bat`.

## Summary
-   **Total Automatable Checks**: ~9
-   **Manual Checks**: UI/UX
