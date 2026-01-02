# Aether Project - Global Rules

## Stack: SPEL-AI (Pure Elixir)
- **S**velte 5 (Runes: `$state`, `$derived`, `$effect`)
- **P**hoenix 1.8+
- **E**lixir/Erlang BEAM
- **L**ucide Icons + Tailwind CSS + DaisyUI

## Core Principles

### 1. The Unbreakable Zig Protocol
Native Implemented Functions (NIFs) are allowed **ONLY** via Zig and **ONLY** if they follow the Unbreakable Protocol:
- Managed binary (`local_zig: true`)
- No global state.
- Memory safety via BEAM allocator.

### 2. Agent Architecture
All IDE functionality is implemented as GenServer agents:
- `FileServerAgent` - File I/O
- `TestingAgent` - Test runner
- `LintAgent` - Code quality
- `FormatAgent` - Code formatting
- (Future) `RefactorAgent`, `DocAgent`, `CIAgent`, `CommanderAgent`

### 3. Windows Compatibility
- Use `.bat` scripts for launching
- Use `cmd /c` for commands in watchers
- Configure PATH explicitly in scripts

### 4. Documentation Requirements
After each work session:
1. Update `docs/DEVLOG.md` - Session summary
2. Update `docs/WALKTHROUGH.md` - Detailed steps
3. Update `docs/AGENTS.md` - New agent APIs

### 5. Commit Standards
Use conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code restructuring
- `test:` - Test changes

## File Structure
```
Aether/
├── .agent/workflows/     # AI workflow definitions
├── assets/               # Svelte frontend
│   └── src/
├── config/               # Elixir config
├── docs/                 # Project documentation
│   ├── AGENTS.md
│   ├── CONSTITUTION.md
│   ├── DEVLOG.md
│   ├── LESSONS_LEARNED.md
│   ├── WALKTHROUGH.md
│   └── WORKFLOW.md
├── lib/
│   ├── aether/
│   │   └── agents/       # GenServer agents
│   └── aether_web/
│       └── channels/     # Phoenix channels
├── priv/
├── test/
├── mix.exs
└── start_dev.bat
```

## Quick Commands
```bash
# Start development
.\start_dev.bat

# Run tests
mix test

# Lint code
mix credo --strict

# Format code
mix format

# Push to GitHub
git add . && git commit -m "..." && git push
```
