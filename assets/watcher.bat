@echo off
setlocal
cd "%~dp0"

where bun >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo 🐇 [Watcher] Starting Bun...
    bun run dev
) else (
    echo 🐢 [Watcher] Bun not found. Starting NPM...
    npm run dev
)
endlocal
