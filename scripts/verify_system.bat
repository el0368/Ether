@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

echo 🔍 [Verification] Starting System Integrity Check...

:: 1. Backend Unit Tests
echo.
echo 🧪 [Backend] Running Elixir Tests...
call mix test
if %ERRORLEVEL% neq 0 (
    echo ❌ [Backend] Tests Failed!
    exit /b 1
)

:: 2. NIF Compilation
echo.
echo 🛠️ [Native] Verifying Zig Build...
cd native/scanner
call zig build
if %ERRORLEVEL% neq 0 (
    echo ❌ [Native] Zig Build Failed!
    cd ../..
    exit /b 1
)
cd ../..

:: 3. Frontend Build (Polyglot)
echo.
echo ⚡ [Frontend] Verifying Svelte Build...
cd assets

where bun >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo 🐇 [Info] Using Bun toolchain.
    call bun install
    if !ERRORLEVEL! neq 0 (
        echo ❌ [Frontend] Bun Install Failed!
        cd ..
        exit /b 1
    )
    call bun x vite build
) else (
    echo 🐢 [Info] Bun not found. Using NPM fallback.
    call npm install
    if !ERRORLEVEL! neq 0 (
        echo ❌ [Frontend] NPM Install Failed!
        cd ..
        exit /b 1
    )
    call npm run build
)

if %ERRORLEVEL% neq 0 (
    echo ❌ [Frontend] Build Failed!
    cd ..
    exit /b 1
)
cd ..

echo.
echo ✅ [Success] System Integrity Verified. All systems operational.
echo    - Elixir: OK
echo    - Zig NIF: OK
echo    - Frontend: OK
exit /b 0
