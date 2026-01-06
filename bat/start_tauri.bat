@echo off
echo ============================================
echo   Ether IDE - Tauri Desktop Mode
echo ============================================

:: 📂 DIRECTORY SETUP - Target parent of 'bat' folder
cd /d "%~dp0.."

:: 🧹 Kill zombies first
call bat\kill_zombies.bat

echo.
echo Starting Tauri Development Server...
echo.

:: Start Tauri (uses Vite + Rust)
cd assets
bun run tauri dev
