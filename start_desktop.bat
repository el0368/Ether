@echo off
echo ============================================
echo   Ether IDE - Desktop Mode
echo ============================================

REM Set PATH for Elixir, Erlang, Git, Node.js
:: set PATH=C:\Elixir\elixir-otp-28\bin;C:\Program Files\Erlang OTP\bin;C:\Program Files\Git\cmd;C:\Program Files\nodejs;C:\Windows\system32;C:\Windows

echo.
echo Starting Ether Desktop...
echo.

REM Start with desktop window
iex -S mix phx.server -e "Ether.Desktop.start_link()"
