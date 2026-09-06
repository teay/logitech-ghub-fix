#!/usr/bin/env bash
# Portable WSL launcher for Fix-LGHUB.ps1
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WIN_PATH="$(wslpath -w "$SCRIPT_DIR/Fix-LGHUB.ps1")"

echo "Executing Logitech G HUB Fixer from WSL..."
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$WIN_PATH"
