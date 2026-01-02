@echo off
set "PATH=C:\Program Files\Elixir\26\bin;C:\Program Files\Erlang OTP\262516\bin;%PATH%"
set "LIB=C:\Program Files\Erlang OTP\262516\usr\lib;%LIB%"
call mix run scripts/verify_native.exs
