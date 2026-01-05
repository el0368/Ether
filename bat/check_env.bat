@echo off
setlocal EnableDelayedExpansion
title Aether Environment Check

:: 📂 DIRECTORY SETUP - Target parent of 'bat' folder
cd /d "%~dp0.."

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
echo   AETHER IDE - Environment Verification
echo  ============================================
echo.

set "INSTALLED_TOOLS="
set "MISSING_TOOLS="
set "OPTIONAL_MISSING="

:: ------------------------------------------------
:: 1. ELIXIR
:: ------------------------------------------------
echo [1/8] Checking Elixir...
call elixir --version >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo      %YELLOW%[X] Not Found%RESET%
    set "MISSING_TOOLS=!MISSING_TOOLS! Elixir"
) else (
    for /f "tokens=*" %%i in ('elixir --version 2^>nul ^| findstr /R "^Elixir"') do echo      %GREEN%[OK] %%i%RESET%
    set "INSTALLED_TOOLS=!INSTALLED_TOOLS! Elixir"
)

:: ------------------------------------------------
:: 2. ERLANG
:: ------------------------------------------------
echo [2/8] Checking Erlang/OTP...
call erl -eval "erlang:display(erlang:system_info(otp_release)), halt()." -noshell >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo      %YELLOW%[X] Not Found%RESET%
    set "MISSING_TOOLS=!MISSING_TOOLS! Erlang"
) else (
    echo      %GREEN%[OK] Erlang Verified%RESET%
    set "INSTALLED_TOOLS=!INSTALLED_TOOLS! Erlang"
)

:: ------------------------------------------------
:: 3. ZIG
:: ------------------------------------------------
echo [3/8] Checking Zig...
zig version >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo      %YELLOW%[X] Not Found%RESET%
    set "MISSING_TOOLS=!MISSING_TOOLS! Zig"
) else (
    for /f "tokens=*" %%i in ('zig version') do echo      %GREEN%[OK] Zig %%i%RESET%
    set "INSTALLED_TOOLS=!INSTALLED_TOOLS! Zig"
)

:: ------------------------------------------------
:: 4. RUST
:: ------------------------------------------------
echo [4/8] Checking Rust...
rustc --version >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo      %YELLOW%[X] Not Found%RESET%
    set "MISSING_TOOLS=!MISSING_TOOLS! Rust"
) else (
    for /f "tokens=*" %%i in ('rustc --version') do echo      %GREEN%[OK] %%i%RESET%
    set "INSTALLED_TOOLS=!INSTALLED_TOOLS! Rust"
)

:: ------------------------------------------------
:: 5. BUN
:: ------------------------------------------------
echo [5/8] Checking Bun...
call bun --version >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo      %YELLOW%[X] Not Found%RESET%
    set "MISSING_TOOLS=!MISSING_TOOLS! Bun"
) else (
    for /f "tokens=*" %%i in ('call bun --version') do echo      %GREEN%[OK] Bun %%i%RESET%
    set "INSTALLED_TOOLS=!INSTALLED_TOOLS! Bun"
)

:: ------------------------------------------------
:: 6. NODE.JS (Optional if Bun exists, but good to have)
:: ------------------------------------------------
echo [6/8] Checking Node.js...
node --version >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo      %YELLOW%[?] Not Found (Optional^)%RESET%
    set "OPTIONAL_MISSING=!OPTIONAL_MISSING! Node.js"
) else (
    for /f "tokens=*" %%i in ('node --version') do echo      %GREEN%[OK] Node.js %%i%RESET%
    set "INSTALLED_TOOLS=!INSTALLED_TOOLS! Node.js"
)

:: ------------------------------------------------
:: 7. POSTGRESQL (Optional)
:: ------------------------------------------------
echo [7/8] Checking PostgreSQL...
psql --version >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo      %YELLOW%[?] Not Found (Optional^)%RESET%
    set "OPTIONAL_MISSING=!OPTIONAL_MISSING! PostgreSQL"
) else (
    for /f "tokens=1-3" %%i in ('psql --version') do echo      %GREEN%[OK] %%i %%j %%k%RESET%
    set "INSTALLED_TOOLS=!INSTALLED_TOOLS! PostgreSQL"
)

:: ------------------------------------------------
:: 8. GIT
:: ------------------------------------------------
echo [8/8] Checking Git...
git --version >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo      %YELLOW%[X] Not Found%RESET%
    set "MISSING_TOOLS=!MISSING_TOOLS! Git"
) else (
    for /f "tokens=*" %%i in ('git --version') do echo      %GREEN%[OK] %%i%RESET%
    set "INSTALLED_TOOLS=!INSTALLED_TOOLS! Git"
)

echo.
echo  ============================================
echo   SUMMARY REPORT
echo  ============================================
echo.

if "%INSTALLED_TOOLS%"=="" (
    echo   [ NONE INSTALLED ]
) else (
    echo   %GREEN%[+] INSTALLED AND READY:%RESET%
    for %%i in (!INSTALLED_TOOLS!) do echo       - %%i
)

echo.

if "%MISSING_TOOLS%"=="" (
    echo   %GREEN%[+] SUCCESS: NO CRITICAL TOOLS MISSING%RESET%
    echo.
    echo   You are ready to run: .\bat\start_dev.bat
) else (
    echo   %RED%[-] MISSING CRITICAL TOOLS:%RESET%
    for %%i in (!MISSING_TOOLS!) do echo       - %YELLOW%%%i%RESET%
    echo.
    echo   %RED%PLEASE INSTALL THE MISSING TOOLS ABOVE.%RESET%
)

if not "%OPTIONAL_MISSING%"=="" (
    echo.
    echo   %YELLOW%[?] Missing Optional Tools:%RESET%
    for %%i in (!OPTIONAL_MISSING!) do echo       - %%i
)

echo.
echo  ============================================
echo %RESET%
echo.
pause
