@echo off
echo ============================================
echo   Aether IDE - Desktop Mode
echo ============================================

REM Set PATH for Elixir, Erlang, Git, Node.js
set PATH=C:\elixir-otp-28\bin;C:\Program Files\Erlang OTP\bin;C:\Program Files\Git\cmd;C:\Program Files\nodejs;C:\Windows\system32;C:\Windows

echo.
echo Starting Aether Desktop...
echo.

REM Start with desktop window
iex -S mix phx.server -e "Aether.Desktop.start_link()"
