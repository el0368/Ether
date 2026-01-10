# Required Versions for Aether IDE

This document lists all dependencies and their tested/required versions.
Run `check_env.bat` to verify your environment.

## Core Runtime

| Tool | Required Version | Install Command / Notes |
|------|------------------|-------------------------|
| Elixir | 1.18+ | `winget install ElixirLang.Elixir` |
| Erlang/OTP | 27+ | Installed with Elixir |
| Zig | 0.14+ | `winget install zig.zig` or download from ziglang.org |
| Rust | 1.75+ | `winget install Rustlang.Rust.GNU` |
| Bun | 1.0+ | `powershell -c "irm bun.sh/install.ps1\|iex"` |

## Optional (But Recommended)

| Tool | Version | Notes |
|------|---------|-------|
| PostgreSQL | 16+ | Only needed if `Aether.Repo` is enabled |
| Node.js | 20+ | Fallback if Bun unavailable |
| Git | 2.40+ | Version control |

## Build Tools (Windows Specific)

| Tool | Notes |
|------|-------|
| Visual Studio Build Tools | Required for Rust native compilation |
| Windows SDK | Usually included with VS Build Tools |

## Quick Setup Commands

```powershell
# Install all via winget (if available)
winget install ElixirLang.Elixir
winget install zig.zig
winget install Rustlang.Rust.GNU
winget install Git.Git

# Install Bun
powershell -c "irm bun.sh/install.ps1|iex"

# Verify installation
.\check_env.bat
```

## Quick Start (New PC Setup)

```bash
# 1. Clone the repository
git clone https://github.com/el0368/Ether.git
cd Ether

# 2. Verify environment (checks installed tools)
.\check_env.bat

# 3. Fix any missing tools (see install commands above)

# 4. Install dependencies
mix deps.get
cd assets && bun install && cd ..

# 5. Verify everything works
.\verify_setup.bat

# 6. Run the application
.\start_dev.bat
# OR run manually:
#   Terminal 1: .\run_backend.bat
#   Terminal 2: cargo tauri dev
```

## What verify_setup.bat Tests

| Test | What it Checks |
|------|----------------|
| Elixir Compile | Backend code compiles without errors |
| NIF Scanner | Zig NIF (scanner.dll) was built correctly |
| Frontend Deps | node_modules exists (bun install worked) |
| Vite Build | Frontend builds without errors |
| Backend Startup | Phoenix server starts on port 4000 |
| Tauri Config | tauri.conf.json exists |

## Quick Setup Commands (Windows)

### If PostgreSQL is NOT installed:
- The `Aether.Repo` is already disabled in `application.ex`
- No database features will work, but file explorer works fine

### If Zig compile fails:
- Ensure Visual Studio Build Tools are installed
- Ensure `zig` is in your PATH

### If `start_dev.bat` fails:
1. Try running backend manually: `cmd /c mix phx.server`
2. Try running frontend manually: `cd assets && bun run tauri dev`
