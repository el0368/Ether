@echo off
setlocal EnableDelayedExpansion

echo [Aether] Building Native Scanner via Manual Protocol...

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
    if exist "C:\Program Files\Erlang OTP" (
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
set "ERL_INCLUDE=%ERTS_DIR%\include"

if not exist "%ERL_INCLUDE%\erl_nif.h" (
    echo [Error] erl_nif.h not found in %ERL_INCLUDE%
    exit /b 1
)

echo [Info] Erlang Includes: %ERL_INCLUDE%

:: Execute Zig Build
pushd native\scanner
if %ERRORLEVEL% neq 0 exit /b 1

echo [Info] Running Zig Build...
zig build -Doptimize=ReleaseFast "-Derl_include=%ERL_INCLUDE%"
if %ERRORLEVEL% neq 0 (
    echo [Error] Zig build failed.
    popd
    exit /b 1
)

popd

:: Deploy Artifact
if not exist "priv\native" mkdir "priv\native"
copy /Y "native\scanner\zig-out\bin\scanner_nif.dll" "priv\native\scanner_nif.dll" >nul
if %ERRORLEVEL% neq 0 (
    echo [Error] Failed to copy artifact.
    exit /b 1
)

echo [Success] Native Scanner compiled and deployed to priv/native/scanner_nif.dll.
