@echo off
set "PATH=C:\Program Files\nodejs;C:\Program Files\Git\cmd;C:\Elixir\elixir-otp-28\bin;C:\Program Files\Erlang OTP\bin;%PATH%"
call mix clean
call mix compile
call mix run --no-start scripts/verify_native.exs
