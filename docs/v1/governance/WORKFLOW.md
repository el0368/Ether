# Aether IDE - Development Workflows
**Last Updated:** 2026-01-01

---

## Quick Start

```bash
# 1. Launch the server (Windows)
.\start_dev.bat

# 2. Open in browser
http://localhost:4000
```

---

## Common Tasks

### Starting Fresh
```bash
mix deps.get
mix ecto.create
mix phx.server
```

### Running Tests
```bash
mix test
```

### Formatting Code
```bash
mix format
```

### Checking Code Quality
```bash
mix credo
```

---

## Adding New Features

### 1. New Agent
1. Create `lib/aether/agents/my_agent.ex`
2. Implement GenServer with `start_link/1` and `init/1`
3. Add to supervision tree in `lib/aether/application.ex`
4. Add channel handler in `lib/aether_web/channels/editor_channel.ex`

### 2. New Svelte Component
1. Create `assets/js/components/MyComponent.svelte`
2. Use Svelte 5 runes: `$state`, `$derived`, `$effect`
3. Import channel from `app.js`

### 3. New API Endpoint
1. Add route in `lib/aether_web/router.ex`
2. Create controller in `lib/aether_web/controllers/`
3. Add tests in `test/aether_web/controllers/`

---

## Troubleshooting

### "mix.ps1 cannot be loaded"
Use CMD instead: `cmd /c "mix phx.server"`

### Database connection failed
Check password in `config/dev.exs`

### NPM watcher errors
Ensure `C:\Program Files\nodejs` is in PATH

### Compilation errors after config changes
```bash
mix clean
mix deps.get
mix compile
```

---

## Hybrid Engine Management (Level 6 Active)
### Safe Mode (Fallback)
If the native DLL is missing or fails to load, `Ether.Native.Scanner` automatically falls back to:
- `scan/1`: Returns `{:error, :nif_not_loaded}`
- **Note**: Pure Elixir fallback was removed in Level 4 to ensure strict native reliability.

### Native Compilation (Zig)
The `native/scanner` project is compiled independently of Mix to avoid toolchain conflicts.

**To Rebuild NIF:**
```bash
.\scripts\build_nif.bat
```
*   Compiles `scanner_safe.zig` (and modules) + `entry.c`
*   Links against Erlang `erts-16.x` includes
*   Outputs `priv/native/scanner_nif.dll`

### Troubleshooting "Permission Denied"
If `mix compile` fails with `permission denied` on `scanner_nif.dll`:
1.  **Kill Zombie Processes**: Run `.\bat\kill_zombies.bat`
2.  **Retry**: `mix compile`

---

## Agent Usage (Phase 4)

### RefactorAgent
Safely rename variables:
```elixir
code = "def hello, do: :world"
{:ok, new_code} = Aether.Agents.RefactorAgent.rename_variable(code, "hello", "greet")
```

### GitAgent
Control version control:
```elixir
Aether.Agents.GitAgent.status()
Aether.Agents.GitAgent.add(".", ["mix.exs"])
Aether.Agents.GitAgent.commit(".", "feat: awesome change")
```

### CommandAgent
Run system commands safely:
```elixir
Aether.Agents.CommandAgent.exec("echo", ["hello"])
```
