@echo off
setlocal EnableDelayedExpansion

echo 🚀 [Aether] Executing Ignition Protocol...

:: 🛠️ AUTO-DETECT VISUAL STUDIO ENVIRONMENT (Self-Healing)
where nmake >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo 🔍 [Aether] NMake not in PATH. Sources VS Build Tools...
    set "VS_DEV_CMD=C:\Program Files\Microsoft Visual Studio\18\Community\Common7\Tools\VsDevCmd.bat"
    if exist "!VS_DEV_CMD!" (
        call "!VS_DEV_CMD!" >nul
        echo 🟢 [Aether] VS Environment Loaded.
    ) else (
        echo 🔴 [Error] VS Build Tools missing. Ignition Aborted.
        exit /b 1
    )
)

:: 📦 IGNITION SEQUENCE
echo 🧪 [Init] Setting Deep Ignition Linker Paths...
set "LIB=C:\Program Files\Erlang OTP\erts-16.2\lib;%LIB%"

echo 📦 [1/3] Fetching Dependencies...
call mix deps.get
echo 📦 [2/3] Fetching Zig Engine...
call mix zig.get
echo ⚡ [3/3] Compiling & Verifying Native Scanner...
call mix compile --force
call elixir verify_bridge.exs

echo ✅ Ignition Sequence Complete.
endlocal
