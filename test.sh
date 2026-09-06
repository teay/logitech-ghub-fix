#!/usr/bin/env bash
# Automated test runner for WSL
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WIN_TEST_PATH="$(wslpath -w "$SCRIPT_DIR/Test-FixLGHUB.ps1")"

echo "Executing Automated Verification Suite from WSL..."
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$WIN_TEST_PATH"
