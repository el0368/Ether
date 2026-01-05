@echo off
setlocal EnableDelayedExpansion
title Ether Setup Verification

:: Define ANSI Colors
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"
)
set "RESET=%ESC%[0m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RED=%ESC%[91m"
set "BOLD=%ESC%[1m"

:: Reset color
echo %RESET%
cls

echo.
echo  ============================================
echo   ETHER IDE - Full Setup Verification
echo  ============================================
echo   This will test all parts of your project.
echo  ============================================
echo.

set ERRORS=0
set TESTS_PASSED=0
set TESTS_TOTAL=7

:: ------------------------------------------------
:: 1. BACKEND COMPILATION
:: ------------------------------------------------
echo [TEST 1/7] Compiling Elixir Backend...
call cmd /c mix compile >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo   %RED%[FAIL] Elixir compilation failed!%RESET%
    echo          Run: mix compile
    set /a ERRORS+=1
) else (
    echo   %GREEN%[PASS] Elixir backend compiles successfully%RESET%
    set /a TESTS_PASSED+=1
)

:: ------------------------------------------------
:: 2. NIF SCANNER
:: ------------------------------------------------
echo [TEST 2/7] Checking NIF Scanner...
set "SCANNER_FOUND=0"
if exist "priv\native\scanner_nif.dll" set "SCANNER_FOUND=1"
if exist "_build\dev\lib\ether\priv\native\scanner_nif.dll" set "SCANNER_FOUND=1"
if exist "native\scanner\scanner_nif.dll" set "SCANNER_FOUND=1"

if "!SCANNER_FOUND!"=="1" (
    echo   %GREEN%[PASS] NIF scanner.dll exists%RESET%
    set /a TESTS_PASSED+=1
) else (
    echo   %RED%[FAIL] NIF scanner.dll not found!%RESET%
    echo          Run: mix compile ^(Zig NIF should auto-build^)
    set /a ERRORS+=1
)

:: ------------------------------------------------
:: 3. FRONTEND DEPS
:: ------------------------------------------------
echo [TEST 3/7] Checking Frontend Dependencies...
if exist "assets\node_modules\" (
    echo   %GREEN%[PASS] Frontend node_modules exists%RESET%
    set /a TESTS_PASSED+=1
) else (
    echo   %RED%[FAIL] Frontend dependencies missing!%RESET%
    echo          Run: cd assets ^&^& bun install
    set /a ERRORS+=1
)

:: ------------------------------------------------
:: 4. FRONTEND BUILD
:: ------------------------------------------------
echo [TEST 4/7] Testing Vite Build...
cd assets
if exist "dist" rd /s /q "dist" >nul 2>&1
call bun run build >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo   %RED%[FAIL] Vite build failed!%RESET%
    echo          Run: cd assets ^&^& bun run build
    set /a ERRORS+=1
) else (
    echo   %GREEN%[PASS] Vite frontend builds successfully%RESET%
    set /a TESTS_PASSED+=1
)
cd ..

:: ------------------------------------------------
:: 5. BACKEND STARTUP
:: ------------------------------------------------
echo [TEST 5/7] Testing Backend Startup (10 second check)...
:: Kill any existing BEAM instances
taskkill /f /im beam.smp.exe >nul 2>&1

:: Start backend in background
start /b cmd /c "mix phx.server" >nul 2>&1

:: Wait and check port 4000 using PowerShell
timeout /t 8 /nobreak >nul
powershell -Command "if ((Test-NetConnection localhost -Port 4000).TcpTestSucceeded) { exit 0 } else { exit 1 }" >nul 2>&1

if !ERRORLEVEL! EQU 0 (
    echo   %GREEN%[PASS] Backend starts and listens on port 4000%RESET%
    set /a TESTS_PASSED+=1
) else (
    echo   %RED%[FAIL] Backend did not start or port 4000 is blocked!%RESET%
    echo          Try running: cmd /c "for /f \"tokens=5\" %%a in ('netstat -ano ^| findstr :4000') do taskkill /f /pid %%a"
    set /a ERRORS+=1
)

:: Cleanup backend
taskkill /f /im beam.smp.exe >nul 2>&1

:: ------------------------------------------------
:: 6. TAURI CONFIG
:: ------------------------------------------------
echo [TEST 6/7] Checking Tauri Configuration...
if exist "src-tauri\tauri.conf.json" (
    echo   %GREEN%[PASS] Tauri configuration exists%RESET%
    set /a TESTS_PASSED+=1
) else (
    echo   %RED%[FAIL] Tauri configuration missing!%RESET%
    set /a ERRORS+=1
)

:: ------------------------------------------------
:: 7. TAURI CLI (CARGO)
:: ------------------------------------------------
echo [TEST 7/7] Checking Tauri CLI (Cargo)...
where cargo-tauri >nul 2>&1
if !ERRORLEVEL! EQU 0 (
    echo   %GREEN%[PASS] cargo-tauri is installed%RESET%
    set /a TESTS_PASSED+=1
) else (
    :: Check if 'cargo tauri' works as a command
    call cargo tauri --version >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo   %GREEN%[PASS] cargo tauri is ready%RESET%
        set /a TESTS_PASSED+=1
    ) else (
        echo   %RED%[FAIL] cargo tauri command not found!%RESET%
        echo          Run: cargo install tauri-cli --locked
        set /a ERRORS+=1
    )
)

echo.
echo  ============================================
echo   VERIFICATION RESULTS
echo  ============================================
echo   Tests Passed: !TESTS_PASSED! / !TESTS_TOTAL!
echo.

if !ERRORS! GTR 0 (
    echo   %RED%STATUS: !ERRORS! TEST^(S^) FAILED%RESET%
    echo.
    echo   Fix the issues above before running Ether.
) else (
    echo   %GREEN%STATUS: ALL TESTS PASSED!%RESET%
    echo.
    echo   You can now run: .\start_dev.bat
    echo   Or manually:
    echo     Terminal 1: .\run_backend.bat
    echo     Terminal 2: cargo tauri dev
)
echo  ============================================
echo %RESET%
echo.
pause
