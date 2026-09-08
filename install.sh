#!/usr/bin/env bash
# Installs 'fix-ghub' command to WSL and creates a Windows Desktop shortcut
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BIN_DIR="$HOME/bin"

mkdir -p "$BIN_DIR"

# 1. สร้างคำสั่ง fix-ghub ใน WSL (~/bin)
cat << EOF > "$BIN_DIR/fix-ghub"
#!/usr/bin/env bash
WIN_PATH="\$(wslpath -w "$SCRIPT_DIR/Fix-LGHUB.ps1")"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\$WIN_PATH"
EOF

chmod +x "$BIN_DIR/fix-ghub"
chmod +x "$SCRIPT_DIR/fix-ghub.sh"

# เพิ่ม ~/bin เข้า PATH ถ้ายังไม่มี
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    if ! grep -q 'HOME/bin' "$HOME/.bashrc" 2>/dev/null; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    fi
fi

# 2. ค้นหาโฟลเดอร์ Desktop บน Windows
USER_PROFILE="$(wslpath -u "$(powershell.exe -NoProfile -Command '[Environment]::GetFolderPath("UserProfile")' | tr -d '\r')")"
WIN_DESKTOP="$USER_PROFILE/Desktop"

# 3. สร้างไฟล์ Fix-GHUB.bat ไว้ที่ Windows Desktop
if [ -d "$WIN_DESKTOP" ]; then
    cat << EOF > "$WIN_DESKTOP/Fix-GHUB.bat"
@echo off
title Fixing Logitech G HUB via WSL...
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
wsl bash -c "cd '$SCRIPT_DIR' && ./fix-ghub.sh"
timeout /t 3
EOF
    echo " [+] Created 'Fix-GHUB.bat' on Windows Desktop!"
fi

echo "=================================================="
echo " Successfully installed 'fix-ghub' command for WSL & Windows!"
echo " Repository path: $SCRIPT_DIR"
echo " You can run 'fix-ghub' in WSL or double-click Fix-GHUB.bat on Desktop."
echo "=================================================="