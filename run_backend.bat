@echo off
cd /d "%~dp0"
echo Starting Ether Backend...
call "%~dp0\bat\kill_zombies.bat"
call cmd /c mix phx.server
pause
