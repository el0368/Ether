@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

echo 🌌 [Aether] Initializing Industrial Environment...

:: 🛠️ ENVIRONMENT CONFIG
:: Removed hardcoded paths to rely on system PATH, or set them correctly if needed.
:: set "PATH=C:\Program Files\nodejs;C:\Program Files\Git\cmd;C:\Elixir\elixir-otp-28\bin;C:\Program Files\Erlang OTP\bin;%PATH%"

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
:: 📦 DEPENDENCY & TOOLING SYNC
if not exist "deps" (
    echo 📦 [Aether] Getting Dependencies...
    call mix deps.get
) else (
    echo ⏩ [Aether] Deps found. Skipping fetch...
)

echo 💾 [Aether] Setting up Database...
:: Only run migration if needed (simplification: assume setup works if repo exists, 
:: or maybe just run migrate? ecto.setup does create+migrate+seed).
:: Let's keep ecto.setup but maybe it's slow?
:: For dev speed, we assume DB is fine if we aren't changing schemas.
:: Reducing content: Just run migrate to be safe but fast.
call mix ecto.migrate

echo 🛠️ [Aether] Building Native Scanner...
if exist "priv\native\scanner_nif.dll" (
    echo ⏩ [Aether] Native Scanner already built. Skipping...
) else (
    call scripts\build_nif.bat
)
:: In Safe Mode, we skip zig.get entirely to avoid errors
:: call mix zig.get 2>nul 

:: 🚀 LAUNCH IEX SESSION
:: 🚀 LAUNCH FRONTEND SETUP
cd assets
if not exist "node_modules" (
    where bun >nul 2>nul
    if !ERRORLEVEL! equ 0 (
        echo 🐇 [Frontend] Using Bun...
        call bun install
    ) else (
        echo 🐢 [Frontend] Bun not found. Falling back to NPM...
        call npm install
    )
) else (
    echo ⏩ [Frontend] node_modules found. Skipping install...
)
cd ..

:: 🚀 ORCHESTRATED LAUNCH
echo 🚀 [Aether] Launching Brain (Elixir)...

:: Start Backend in separate window
start "Aether Backend" cmd /c "mix phx.server"

:: Wait for Backend to be ready
echo ⏳ Waiting for Backend to ignite...
:loop
curl -s http://localhost:4000 >nul
if %ERRORLEVEL% neq 0 (
    timeout /t 1 /nobreak >nul
    goto loop
)

echo 🟢 Backend is ALIVE. Launching UI Shell...
:: Assume cargo is in path, or use tauri cli if available. User said "cargo tauri dev"
cargo tauri dev

endlocal
