#!/usr/bin/env bash
# Installs 'fix-ghub' command to user's ~/bin directory in WSL
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BIN_DIR="$HOME/bin"

mkdir -p "$BIN_DIR"

cat << EOF > "$BIN_DIR/fix-ghub"
#!/usr/bin/env bash
WIN_PATH="\$(wslpath -w "$SCRIPT_DIR/Fix-LGHUB.ps1")"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "\$WIN_PATH"
EOF

chmod +x "$BIN_DIR/fix-ghub"
chmod +x "$SCRIPT_DIR/fix-ghub.sh"

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    if ! grep -q 'HOME/bin' "$HOME/.bashrc" 2>/dev/null; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    fi
fi

echo "=================================================="
echo " Successfully installed 'fix-ghub' command for WSL!"
echo " Repository path: $SCRIPT_DIR"
echo " You can now run 'fix-ghub' from anywhere."
echo "=================================================="
