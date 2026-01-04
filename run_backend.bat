@echo off
cd /d "%~dp0"
echo Starting Aether Backend...
call cmd /c mix phx.server
pause
