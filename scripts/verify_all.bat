@echo off
set "PATH=C:\Program Files\nodejs;C:\Program Files\Git\cmd;C:\Elixir\elixir-otp-28\bin;C:\Program Files\Erlang OTP\bin;%PATH%"

echo ========================================================
echo [LEVEL 1] Verifying Native Core (Zig NIF)...
echo ========================================================
call scripts\verify_unicode.bat
if %errorlevel% neq 0 (
    echo [ERROR] Native Core Verification Failed!
    exit /b %errorlevel%
)

echo.
echo ========================================================
echo [LEVEL 2] Verifying Application Integration...
echo ========================================================
call scripts\verify_app.bat
if %errorlevel% neq 0 (
    echo [ERROR] App Integration Verification Failed!
    exit /b %errorlevel%
)

echo.
echo ========================================================
echo [LEVEL 3] Verifying Backend Logic (Unit Tests)...
echo ========================================================
call mix test
if %errorlevel% neq 0 (
    echo [ERROR] Backend Logic Tests Failed!
    exit /b %errorlevel%
)

echo.
echo ========================================================
echo [SUCCESS] ALL SYSTEMS GREEN.
echo ========================================================
exit /b 0
