@echo off
echo [Cleaner] Checking for zombie processes...

:: Run the smart cleanup PowerShell script
powershell -ExecutionPolicy Bypass -File "%~dp0smart_cleanup.ps1"

:: Fallback: Port-based cleanup for reliability
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :4000 ^| findstr LISTENING') do (
    echo       Killing zombie backend on port 4000 (PID: %%a)
    taskkill /F /PID %%a >nul 2>nul
)

echo [Cleaner] Port 4000 is clear.
