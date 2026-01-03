@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

echo 🌌 [Aether] Initializing Industrial Environment...

:: 🛠️ ENVIRONMENT CONFIG
set "PATH=C:\Program Files\nodejs;C:\Program Files\Git\cmd;C:\Elixir\elixir-otp-28\bin;C:\Program Files\Erlang OTP\bin;%PATH%"

where nmake >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo 🔍 [Aether] NMake not in PATH. Attempting to source VS Build Tools...
    set "VS_DEV_CMD=C:\Program Files\Microsoft Visual Studio\18\Community\Common7\Tools\VsDevCmd.bat"
    
    if exist "!VS_DEV_CMD!" (
        echo 🟢 [Aether] Found VS Build Tools. Initializing...
        call "!VS_DEV_CMD!" >nul
    ) else (
        echo 🔴 [Error] VS Build Tools not found.
        echo 💡 [Fix] Please ensure Visual Studio 2022 is installed.
        exit /b 1
    )
)

echo 🛡️ [Path] Developer environment active.

:: 📂 DIRECTORY SETUP
cd /d "%~dp0"

:: 📦 DEPENDENCY & TOOLING SYNC
echo 📦 [Aether] Getting Dependencies...
call mix deps.get

echo 💾 [Aether] Setting up Database...
call mix ecto.setup

echo 🛠️ [Aether] Building Native Scanner...
call scripts\build_nif.bat
:: In Safe Mode, we skip zig.get entirely to avoid errors
:: call mix zig.get 2>nul 

:: 🚀 LAUNCH IEX SESSION
echo 🚀 [Aether] Launching Brain...
iex -S mix phx.server

endlocal
