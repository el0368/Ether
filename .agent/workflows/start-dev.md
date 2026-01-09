---
description: how to start the development server
---

## Start Development Server

// turbo-all

1. Open a terminal in the Aether project directory
2. Run the start script:
   ```cmd
   .\bat\start_tauri.bat
   ```
3. This will launch both the Phoenix backend (port 4000) and the Tauri window.

## Troubleshooting

If you see "mix.ps1 cannot be loaded":
- Use CMD instead of PowerShell, or
- Run: `cmd /c "mix phx.server"`

If database errors appear:
- Check password in `config/dev.exs` (should be `a`)
- Run: `mix ecto.create`
