@echo off
echo ============================================
echo   Aether IDE - Pure Elixir Stack
echo ============================================

REM Set PATH for Elixir, Erlang, Git, Node.js
set PATH=C:\elixir-otp-28\bin;C:\Program Files\Erlang OTP\bin;C:\Program Files\Git\cmd;C:\Program Files\nodejs;C:\Windows\system32;C:\Windows

echo.
echo [CHECK] Elixir Version:
call elixir -v

echo.
echo Ensuring database exists...
call mix ecto.create

echo.
echo Fetching dependencies...
call mix deps.get

echo.
echo Compiling...
call mix compile

echo.
echo ============================================
echo   Starting Phoenix Server...
echo   Open http://localhost:4000
echo ============================================
call mix phx.server
