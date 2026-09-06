@echo off
:: Batch Launcher for Fix-LGHUB.ps1 (Portable)
:: Automatically detects script path relative to current directory

title Logitech G HUB Fixer

net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Requesting Administrator Privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Fix-LGHUB.ps1"
echo.
echo Press any key to exit...
pause >nul
