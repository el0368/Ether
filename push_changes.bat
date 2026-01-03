@echo off
set "PATH=C:\Program Files\Git\cmd;%PATH%"
echo [Git] Adding files...
git add .
echo [Git] Committing...
git commit -m "feat: Upgrade Native Scanner to robust C-NIF with Unicode support"
echo [Git] Pushing...
git push origin main
if %ERRORLEVEL% equ 0 (
    echo [Success] Pushed to GitHub.
) else (
    echo [Error] Push failed.
)
