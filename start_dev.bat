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
echo [1/5] Checking environment...
where mix >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Elixir/Mix not found in PATH!
    echo         Run check_env.bat to diagnose.
    pause
    exit /b 1
)

:: 🧹 KILL ZOMBIE PROCESSES (Port 4000)
echo [2/5] Cleaning up old processes...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :4000 ^| findstr LISTENING') do (
    echo       Killing zombie process on port 4000 (PID: %%a)
    taskkill /F /PID %%a >nul 2>nul
)

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
start "Ether Backend" cmd /k "cd /d %~dp0 && mix phx.server"

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
