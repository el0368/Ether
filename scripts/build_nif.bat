@echo off
setlocal EnableDelayedExpansion

echo [Ether] Building Native Scanner via Manual Protocol...

:: Add known Zig path to environment (Bootstrap)
set "PATH=C:\Users\Administrator\AppData\Local\zigler\Cache\zig-x86_64-windows-0.15.2;%PATH%"

:: Verify Zig availability
where zig >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [Error] Zig compiler not found in PATH or standard location.
    exit /b 1
)

:: Verify Environment
if not defined ERL_ROOT (
    if exist "C:\Program Files\Erlang OTP\283" (
        set "ERL_ROOT=C:\Program Files\Erlang OTP\283"
    ) else if exist "C:\Program Files\Erlang OTP" (
        set "ERL_ROOT=C:\Program Files\Erlang OTP"
    ) else (
        echo [Error] ERL_ROOT not found.
        exit /b 1
    )
)

echo [Info] ERL_ROOT detected: %ERL_ROOT%

:: Locate the include directory (handling version variance if needed)
:: Using quotes in set to handle spaces
for /d %%D in ("%ERL_ROOT%\erts-*") do set "ERTS_DIR=%%D"
if not defined ERTS_DIR (
    echo [Error] No ERTS directory found in %ERL_ROOT%
    dir "%ERL_ROOT%"
    exit /b 1
)
set "ERL_INCLUDE=%ERTS_DIR%\include"

if not exist "%ERL_INCLUDE%\erl_nif.h" (
    echo [Error] erl_nif.h not found in %ERL_INCLUDE%
    exit /b 1
)

echo [Info] Erlang Includes: %ERL_INCLUDE%

:: Execute Zig Build
pushd native\scanner
if %ERRORLEVEL% neq 0 exit /b 1

echo [Info] Running Hybrid Zig Build (Safe Mode)...
:: We compile entry.c (ABI Shim) and scanner_safe.zig (Logic) together.
:: -lc links C runtime (needed for Erlang/Windows)
:: -dynamic produces a DLL
:: --name scanner_nif output filename
zig build-lib -dynamic -O ReleaseFast --name scanner_nif src/entry.c src/scanner_safe.zig -lc "-I%ERL_INCLUDE%"
if %ERRORLEVEL% neq 0 (
    echo [Error] Zig build failed.
    popd
    exit /b 1
)

popd

:: Deploy Artifact
:: Zig outputs to the current directory (native\scanner) by default with build-lib? 
:: Verify output name. usually scanner_nif.dll
if not exist "native\scanner\scanner_nif.dll" (
    echo [Error] DLL not found after build.
    exit /b 1
)

if not exist "priv\native" mkdir "priv\native"
copy /Y "native\scanner\scanner_nif.dll" "priv\native\scanner_nif.dll" >nul
if %ERRORLEVEL% neq 0 (
    echo [Error] Failed to copy artifact.
    exit /b 1
)

echo [Success] Level 4 Scanner (Zig+C) compiled and deployed.
