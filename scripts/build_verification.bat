@echo off
set PATH=C:\elixir-otp-28\bin;C:\Program Files\Erlang OTP\bin;C:\Program Files\Git\cmd;C:\Program Files\nodejs;C:\Windows\system32;C:\Windows

echo Cleaning...
rd /s /q _build
rd /s /q deps

echo.
echo Fetching deps...
call mix deps.get

echo.
echo Fetching Zig...
call mix zig.get

echo.
echo Compiling...
call mix compile

echo.
echo Testing...
call mix test
