@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

echo.
echo  ============================================
echo   AETHER IDE - Development Launcher
echo  ============================================
echo.

:: 📂 DIRECTORY SETUP
cd /d "%~dp0"

:: 🔍 QUICK ENVIRONMENT CHECK
echo [1/4] Checking environment...
where mix >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Elixir/Mix not found in PATH!
    echo         Run check_env.bat to diagnose.
    pause
    exit /b 1
)

:: 📦 DEPENDENCY CHECK
echo [2/4] Checking dependencies...
if not exist "deps" (
    echo       Installing backend dependencies...
    call cmd /c mix deps.get
)

if not exist "assets\node_modules" (
    echo       Installing frontend dependencies...
    cd assets
    call bun install
    cd ..
)

:: 🔨 COMPILE CHECK
echo [3/4] Compiling...
call cmd /c mix compile
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Compilation failed!
    pause
    exit /b 1
)

:: 🚀 LAUNCH
echo [4/4] Launching Aether...
echo.
echo       Starting Backend (Port 4000)...

:: Start Backend in separate window
start "Aether Backend" cmd /k "cd /d %~dp0 && mix phx.server"

:: Wait for Backend to be ready
echo       Waiting for Backend...
:loop
timeout /t 1 /nobreak >nul
curl -s http://localhost:4000 >nul 2>nul
if %ERRORLEVEL% neq 0 (
    goto loop
)

echo       Backend ready!
echo       Starting Frontend (Tauri)...
echo.

:: Launch Tauri (this will open the app window)
cargo tauri dev

endlocal
