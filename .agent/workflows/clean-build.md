---
description: how to do a clean rebuild of the project
---

## Clean Rebuild

Use this when you have strange compilation errors or stale artifacts.

// turbo-all

1. Stop any running servers (Ctrl+C)

2. Clean build artifacts:
   ```cmd
   mix clean
   ```

3. Remove and re-fetch dependencies:
   ```cmd
   rmdir /s /q deps _build
   mix deps.get
   ```

4. Recompile:
   ```cmd
   mix compile
   ```

5. Start server:
   ```cmd
   .\bat\start_tauri.bat
   ```

## When to Use
- After changing `mix.exs` dependencies
- After config changes that aren't being picked up
- When you see "module X is not available" errors
