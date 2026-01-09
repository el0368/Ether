@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

echo.
echo  ============================================
echo   AETHER IDE - Development Launcher
echo  ============================================
echo.

:: 📂 DIRECTORY SETUP - Target parent of 'bat' folder
cd /d "%~dp0.."

:: 🔍 QUICK ENVIRONMENT CHECK
echo [1/5] Checking environment...
where mix >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Elixir/Mix not found in PATH!
    echo         Run bat\check_env.bat to diagnose.
    pause
    exit /b 1
)

:: 🧹 KILL ZOMBIE PROCESSES (Port 4000)
echo [2/5] Cleaning up old processes...
powershell -Command "Get-NetTCPConnection -LocalPort 4000 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }"

:: 📦 DEPENDENCY CHECK
echo [3/5] Checking dependencies...
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
echo [4/5] Compiling...
call cmd /c mix compile
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Compilation failed!
    pause
    exit /b 1
)

:: 🚀 LAUNCH
echo [5/5] Launching Ether...
echo.
echo       Starting Backend (Port 4000)...

:: Start Backend in separate window
start "Aether Backend" cmd /k "mix phx.server"

:: Wait for Backend to be ready
echo       Waiting for Backend...
:loop
timeout /t 1 /nobreak >nul
powershell -Command "if ((Test-NetConnection localhost -Port 4000).TcpTestSucceeded) { exit 0 } else { exit 1 }" >nul 2>&1
if !ERRORLEVEL! neq 0 (
    goto loop
)

echo.
echo       Backend ready!
echo       Starting Frontend (Tauri)...
echo.

:: Launch Tauri via Cargo
cargo tauri dev

endlocal
