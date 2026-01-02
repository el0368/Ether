@echo off
echo ============================================
echo   Aether Environment Auditor
echo ============================================
echo.

set "ERL_ROOT=C:\Program Files\Erlang OTP"
set "ELIXIR_ROOT=C:\elixir-otp-28"

echo [*] Checking Erlang Root: %ERL_ROOT%
if exist "%ERL_ROOT%" (
    echo     [OK] Found.
) else (
    echo     [WARN] Not found at default location.
)

echo.
echo [*] Checking NIF Headers (erl_nif.h)
set "HEADER_FOUND=0"
for /f "delims=" %%D in ('dir /b /s /a-d "%ERL_ROOT%\erl_nif.h" 2^>nul') do (
    echo     [OK] Found: %%D
    set "HEADER_FOUND=1"
)

if "%HEADER_FOUND%"=="0" (
    echo     [FAIL] erl_nif.h NOT found in Erlang OTP directory.
    echo     Zig compilation will likely fail.
)

echo.
echo [*] Checking Build Tools (nmake / cl)
where nmake >nul 2>nul
if %errorlevel%==0 (
    echo     [OK] nmake found.
) else (
    echo     [WARN] nmake not found (Visual Studio Build Tools missing?^)
)

echo.
echo ============================================
echo Audit Complete.
echo ============================================
