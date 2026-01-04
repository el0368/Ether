@echo off
title Aether Setup Verification
color 0A

echo.
echo  ============================================
echo   AETHER IDE - Full Setup Verification
echo  ============================================
echo   This will test all parts of your project.
echo  ============================================
echo.

set ERRORS=0
set TESTS_PASSED=0
set TESTS_TOTAL=6

echo [TEST 1/6] Compiling Elixir Backend...
call cmd /c mix compile >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [FAIL] Elixir compilation failed!
    echo          Run: mix compile
    set /a ERRORS+=1
) else (
    echo   [PASS] Elixir backend compiles successfully
    set /a TESTS_PASSED+=1
)

echo [TEST 2/6] Checking NIF Scanner...
if exist "_build\dev\lib\aether\priv\native\scanner.dll" (
    echo   [PASS] NIF scanner.dll exists
    set /a TESTS_PASSED+=1
) else (
    echo   [FAIL] NIF scanner.dll not found!
    echo          Run: mix compile (Zig NIF should auto-build)
    set /a ERRORS+=1
)

echo [TEST 3/6] Checking Frontend Dependencies...
if exist "assets\node_modules" (
    echo   [PASS] Frontend node_modules exists
    set /a TESTS_PASSED+=1
) else (
    echo   [FAIL] Frontend dependencies missing!
    echo          Run: cd assets ^&^& bun install
    set /a ERRORS+=1
)

echo [TEST 4/6] Testing Vite Build...
cd assets
call bun run build >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [FAIL] Vite build failed!
    echo          Run: cd assets ^&^& bun run build
    set /a ERRORS+=1
) else (
    echo   [PASS] Vite frontend builds successfully
    set /a TESTS_PASSED+=1
)
cd ..

echo [TEST 5/6] Testing Backend Startup (5 second check)...
start /b cmd /c "mix phx.server 2>&1 | findstr /R \"Running.*Endpoint\" > _test_backend.tmp" 
timeout /t 5 /nobreak >nul
taskkill /f /im beam.smp.exe >nul 2>&1
if exist "_test_backend.tmp" (
    for %%A in (_test_backend.tmp) do if %%~zA gtr 0 (
        echo   [PASS] Backend starts and listens on port 4000
        set /a TESTS_PASSED+=1
    ) else (
        echo   [FAIL] Backend did not start properly!
        set /a ERRORS+=1
    )
    del _test_backend.tmp >nul 2>&1
) else (
    echo   [WARN] Could not verify backend startup
)

echo [TEST 6/6] Checking Tauri Configuration...
if exist "src-tauri\tauri.conf.json" (
    echo   [PASS] Tauri configuration exists
    set /a TESTS_PASSED+=1
) else (
    echo   [FAIL] Tauri configuration missing!
    set /a ERRORS+=1
)

echo.
echo  ============================================
echo   VERIFICATION RESULTS
echo  ============================================
echo   Tests Passed: %TESTS_PASSED% / %TESTS_TOTAL%
echo.

if %ERRORS% GTR 0 (
    color 0C
    echo   STATUS: %ERRORS% TEST(S) FAILED
    echo.
    echo   Fix the issues above before running Aether.
) else (
    color 0A
    echo   STATUS: ALL TESTS PASSED!
    echo.
    echo   You can now run: .\start_dev.bat
    echo   Or manually:
    echo     Terminal 1: .\run_backend.bat
    echo     Terminal 2: cargo tauri dev
)
echo  ============================================
echo.

pause
