@echo off
echo [Cleaner] Checking for zombie processes...

:: Port 4000 (Backend - Phoenix/Bandit)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :4000 ^| findstr LISTENING') do (
    echo       Killing zombie backend on port 4000 (PID: %%a)
    taskkill /F /PID %%a >nul 2>nul
)

:: Port 5173 (Frontend - Vite)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5173 ^| findstr LISTENING') do (
    echo       Killing zombie frontend on port 5173 (PID: %%a)
    taskkill /F /PID %%a >nul 2>nul
)

:: Aggressive Cleanup (Ensure DLLs are released)
echo       Ensuring all Erlang processes are dead...
taskkill /F /IM beam.smp.exe >nul 2>nul
taskkill /F /IM erl.exe >nul 2>nul

echo [Cleaner] Ports 4000 and 5173 are clear.
