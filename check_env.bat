@echo off
title Aether Environment Check
color 0A

echo.
echo  ============================================
echo   AETHER IDE - Environment Verification
echo  ============================================
echo.

set ERRORS=0

echo [1/8] Checking Elixir...
elixir --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [X] Elixir: NOT INSTALLED
    set /a ERRORS+=1
) else (
    for /f "tokens=*" %%i in ('elixir --version 2^>nul ^| findstr /R "^Elixir"') do echo   [OK] %%i
)

echo [2/8] Checking Erlang/OTP...
erl -eval "erlang:display(erlang:system_info(otp_release)), halt()." -noshell >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [X] Erlang: NOT INSTALLED
    set /a ERRORS+=1
) else (
    echo   [OK] Erlang installed
)

echo [3/8] Checking Zig...
zig version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [X] Zig: NOT INSTALLED
    set /a ERRORS+=1
) else (
    for /f "tokens=*" %%i in ('zig version') do echo   [OK] Zig %%i
)

echo [4/8] Checking Rust...
rustc --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [X] Rust: NOT INSTALLED
    set /a ERRORS+=1
) else (
    for /f "tokens=*" %%i in ('rustc --version') do echo   [OK] %%i
)

echo [5/8] Checking Bun...
bun --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [X] Bun: NOT INSTALLED
    set /a ERRORS+=1
) else (
    for /f "tokens=*" %%i in ('bun --version') do echo   [OK] Bun %%i
)

echo [6/8] Checking Node.js...
node --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [?] Node.js: NOT INSTALLED (optional if using Bun)
) else (
    for /f "tokens=*" %%i in ('node --version') do echo   [OK] Node.js %%i
)

echo [7/8] Checking PostgreSQL...
psql --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [?] PostgreSQL: NOT INSTALLED (optional - can disable Repo)
) else (
    for /f "tokens=1-3" %%i in ('psql --version') do echo   [OK] %%i %%j %%k
)

echo [8/8] Checking Git...
git --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   [X] Git: NOT INSTALLED
    set /a ERRORS+=1
) else (
    for /f "tokens=*" %%i in ('git --version') do echo   [OK] %%i
)

echo.
echo  ============================================
if %ERRORS% GTR 0 (
    color 0C
    echo   RESULT: %ERRORS% REQUIRED TOOL(S) MISSING!
    echo   Please install missing tools before running Aether.
) else (
    echo   RESULT: All required tools installed!
    echo   You can run: .\start_dev.bat
)
echo  ============================================
echo.

pause
