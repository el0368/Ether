# Aether Project - Global Rules

## Stack: PLEX-Z (Phoenix LiveView Elixir Zig)
- **P**hoenix LiveView 1.0+ (Components, Streams, Hooks)
- **L**ucide Icons + Tailwind CSS (via `heroicons`)
- **E**lixir/Erlang BEAM
- **X**it (Exit) Strategy: No JS Frameworks (Zero Svelte/React)
- **Z**ig (Safe Native Protocol)

## Core Principles

### 1. The Safe Native Zig Protocol (Level 4)
We use a **Hybrid Shim Architecture** to run Safe Zig NIFs on Windows.
- **Shim (`entry.c`)**: Handles Erlang NIF macros.
- **Logic (`*.zig`)**: Pure Zig with `std.fs`, avoiding `windows.h`.
- **Status**: **PRODUCTION-READY** (Level 4 Verified).
- **Strict Policy**: **NO ZIGLER EMBEDDING**. All Zig code lives in `native/`.
- **NO ELIXIR FALLBACK**: If Zig fails, the system must error/crash.

### 2. Component Architecture (Phase 6)
The UI is composed of atomic Phoenix LiveComponents:
- `Workbench.TitleBar`
- `Workbench.ActivityBar`
- `Workbench.Sidebar` (Explorer/Search/Git)
- `Workbench.Editor` (Monaco Bridge)
- `Workbench.Panel` (Terminal)
- `Workbench.StatusBar`

### 3. Agent Architecture
All IDE functionality is implemented as GenServer agents:
- `FileServerAgent` - File I/O
- `TestingAgent` - Test runner
- `LintAgent` - Code quality
- `FormatAgent` - Code formatting
- **Advanced Agents**:
    - `RefactorAgent` (Sourceror)
    - `GitAgent` (System Wrapper)

### 4. Windows Compatibility
- Use `.bat` scripts for launching (`start_tauri.bat`)
- Use `cmd /c` for commands in watchers
- Configure PATH explicitly in scripts

### 5. Documentation Requirements
After each work session:
1. Update `docs/logs/DEVLOG.md` - Session summary
2. Update `docs/reference/WALKTHROUGH.md` - Detailed steps
3. Update `docs/reference/AGENTS.md` - New agent APIs

### 6. Commit Standards
Use conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code restructuring
- `test:` - Test changes

### 7. System Pressure Protocol (ADR-005)
To prevent "White Screen" and "Startup Congestion":
- **Lazy Ignition**: Frontend MUST wait **800ms** after socket connection before requesting heavy data.
- **Throttling**: Scanner/Benchmarks MUST NOT auto-start on channel join.
- **Safety Valve**: UI MUST batch high-frequency events (e.g., 20fps limit) to preventing Event Loop starvation.

## File Structure
```
Aether/
├── .agent/workflows/           # AI workflow definitions
├── assets/                     # JS Hooks (Monaco, WindowControls)
├── config/                     # Elixir config
├── docs/                       # Project documentation
│   ├── governance/             # Rules & Constitution
│   ├── reference/              # Architecture docs
│   └── plans/                  # Future roadmaps
├── lib/
│   ├── ether/
│   │   ├── agents/             # GenServer agents
│   │   └── native/             # NIF loaders
│   └── ether_web/
│       ├── components/         # LiveComponents
│       │   └── workbench/      # IDE Shell Components
│       └── live/               # LiveViews (WorkbenchLive)
├── native/                     # Zig Source Code
│   └── scanner/
├── priv/
├── test/
├── mix.exs
└── bat/                        # Windows Scripts
    └── start_tauri.bat
```

## Quick Start (Windows)
```bash
# Run the Desktop App
.\bat\start_tauri.bat

# Run Tests
mix test

# Run NIF Benchmarks
mix run bench/nif_microbench.exs
```
