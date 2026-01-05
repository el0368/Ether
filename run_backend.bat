@echo off
cd /d "%~dp0"
echo Starting Ether Backend...
call cmd /c mix phx.server
pause
