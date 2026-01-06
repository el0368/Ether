@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

echo.
echo  ============================================
echo   ETHER IDE - Tauri Launcher
echo  ============================================
echo.

:: 📂 DIRECTORY SETUP
:: %~dp0 is the directory containing this script (ends with \)
:: We want the project root, which is the parent of 'bat'
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."

echo [1/3] Navigating to: %PROJECT_ROOT%
cd /d "%PROJECT_ROOT%"

:: 🧹 KILL ZOMBIE PROCESSES
echo [2/3] Cleaning up...
call "bat\kill_zombies.bat"

:: 🚀 LAUNCH
echo [3/3] Launching Ether...
echo.
echo       Starting Backend (Port 4000)...

:: Start Backend in separate window with explicit path quoting
start "Ether Backend" cmd /k "cd /d "%PROJECT_ROOT%" && mix phx.server"

:: Wait for Backend to be ready
echo       Waiting for Backend...
:loop
timeout /t 1 /nobreak >nul
curl -s http://localhost:4000 >nul 2>nul
if %ERRORLEVEL% neq 0 (
    goto loop
)

echo.
echo       Backend ready!
echo       Starting Tauri Development Shell...
echo.

:: Launch Tauri
cargo tauri dev

endlocal
