---
description: How to start the Aether Desktop application
---
# Start Aether Desktop

To start the desktop application (Phoenix LiveView + Tauri), run the provided batch script:

```bash
.\bat\start_tauri.bat
```

This script will:
1.  Set up the necessary environment paths.
2.  Clean up any zombie processes from previous runs.
3.  Launch the Phoenix backend on port 4000.
4.  Launch the Tauri development shell.

## Manual Method (Backdoor)

If `start_tauri.bat` fails, you can run components separately:

1.  **Backend**:
    ```bash
    iex -S mix phx.server
    ```
2.  **Frontend (Tauri)**:
    ```bash
    cargo tauri dev
    ```

> [!NOTE]
> Ensure port 4000 is clear. The `start_tauri.bat` script handles this automatically.
