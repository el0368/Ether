@echo off
set PATH=C:\elixir-otp-28\bin;C:\Program Files\Erlang OTP\bin;C:\Program Files\Git\cmd;C:\Program Files\nodejs;C:\Windows\system32;C:\Windows

echo Running Scanner Tests...
call mix test test/aether/scanner_test.exs
