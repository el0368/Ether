@echo off
set "PATH=C:\Program Files\nodejs;C:\Program Files\Git\cmd;C:\Elixir\elixir-otp-28\bin;C:\Program Files\Erlang OTP\bin;%PATH%"

echo Cleaning...
call mix clean

echo Building NIF...
call scripts\build_nif.bat

echo Verifying Application API...
call mix run --no-start -e "IO.inspect(Aether.Scanner.scan(\".\"))"
