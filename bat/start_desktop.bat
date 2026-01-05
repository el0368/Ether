@echo off
echo ============================================
echo   Aether IDE - Desktop Mode
echo ============================================

:: 📂 DIRECTORY SETUP - Target parent of 'bat' folder
cd /d "%~dp0.."

echo.
echo Starting Aether Desktop...
echo.

:: Start with desktop window
iex -S mix phx.server -e "Aether.Desktop.start_link()"
