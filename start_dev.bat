@echo off
setlocal EnableDelayedExpansion

echo 🌌 [Aether] Initializing Industrial Environment...

:: 🛠️ AUTO-DETECT VISUAL STUDIO ENVIRONMENT
:: This looks for the VS Dev Command script and runs it if nmake isn't found.
where nmake >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo 🔍 [Aether] NMake not in PATH. Attempting to source VS Build Tools...
    
    set "VS_DEV_CMD=C:\Program Files\Microsoft Visual Studio\18\Community\Common7\Tools\VsDevCmd.bat"
    
    if exist "!VS_DEV_CMD!" (
        echo 🟢 [Aether] Found VS Build Tools. Initializing...
        call "!VS_DEV_CMD!" >nul
    ) else (
        echo 🔴 [Error] VS Build Tools not found at expected path: "!VS_DEV_CMD!"
        echo 💡 [Fix] Please ensure Visual Studio 2022 is installed.
        pause
        exit /b 1
    )
)

:: 🛡️ UNBREAKABLE PATH HARDENING
set "OLD_PATH=%PATH%"
set "PATH=%PATH:C:\Zig;=%"
set "PATH=%PATH:C:\Zig=%"

:: 📂 DIRECTORY SETUP
cd /d "%~dp0"

echo 🛡️ [Path] System Zig excluded. Developer environment active.

:: 📦 DEPENDENCY & TOOLING SYNC
echo 📦 [Aether] Syncing dependencies...
call mix deps.get
call mix zig.get 2>nul
if %ERRORLEVEL% neq 0 (
    echo ⚠️ [Aether] Zig engine disabled (Safe Mode). Skipping binary fetch.
)

:: 🚀 LAUNCH IEX SESSION
echo 🚀 [Aether] Launching Brain...
iex -S mix phx.server

endlocal
