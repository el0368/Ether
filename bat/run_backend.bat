@echo off
:: 📂 DIRECTORY SETUP - Target parent of 'bat' folder
cd /d "%~dp0.."
echo Starting Ether Backend...
call cmd /c mix phx.server
pause
