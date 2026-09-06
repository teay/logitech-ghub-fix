@echo off
:: Batch Wrapper to launch Fix-LGHUB.ps1 with Administrator Rights
:: GitHub: https://github.com/your-username/logitech-ghub-fix

title Logitech G HUB Fixer

net session >nul 2>&1
if %errorLevel% == 0 (
    goto :RunScript
) else (
    echo Requesting Administrator Privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:RunScript
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Fix-LGHUB.ps1"
echo.
echo Press any key to exit...
pause >nul
