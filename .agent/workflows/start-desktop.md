---
description: How to start the Aether Desktop application
---
# Start Aether Desktop

To start the desktop application (Elixir Desktop + Phoenix + Svelte), run the provided batch script:

```bash
.\start_desktop.bat
```

This script will:
1.  Set up the necessary environment paths.
2.  Launch the Phoenix server inside an IEx shell.
3.  Automatically start the `Aether.Desktop` window.

## Manual Method

If you prefer to run it manually from IEx:

1.  Start the Phoenix server:
    ```bash
    iex -S mix phx.server
    ```
2.  Inside the IEx shell, launch the desktop window:
    ```elixir
    Aether.Desktop.start_link()
    ```

> [!NOTE]
> If you see an `:eaddrinuse` error, it means the server port (4000) is already taken. Ensure no other instances are running.
