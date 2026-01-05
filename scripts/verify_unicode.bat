@echo off
set "PATH=C:\Program Files\nodejs;C:\Program Files\Git\cmd;C:\Elixir\elixir-otp-28\bin;C:\Program Files\Erlang OTP\bin;%PATH%"

echo Creating Unicode Test Directory...
mkdir "test_🚀_folder" 2>nul
echo "Hello Space" > "test_🚀_folder\hello_world.txt"

echo Cleaning...
call mix clean

echo Building NIF...
call scripts\build_nif.bat

echo Verifying Unicode Support...
call mix run --no-start -e "IO.inspect(Ether.Native.Scanner.scan(\"test_🚀_folder\"))"
