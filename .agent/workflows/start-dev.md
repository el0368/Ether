---
description: how to start the development server
---

## Start Development Server

// turbo-all

1. Open a terminal in the Aether project directory
2. Run the start script:
   ```cmd
   .\start_dev.bat
   ```
3. Wait for the message: `Running AetherWeb.Endpoint with Bandit... at http://localhost:4000`
4. Open browser to http://localhost:4000

## Troubleshooting

If you see "mix.ps1 cannot be loaded":
- Use CMD instead of PowerShell, or
- Run: `cmd /c "mix phx.server"`

If database errors appear:
- Check password in `config/dev.exs` (should be `a`)
- Run: `mix ecto.create`
