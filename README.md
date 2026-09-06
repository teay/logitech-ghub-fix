# Logitech G HUB Admin & Startup Fix 🛠️

Automated PowerShell repair tool for **Logitech G HUB** stuck on startup or requiring "Run as Administrator" privileges on Windows 10/11.

---

## ❓ Problem Overview / สาเหตุของปัญหา

Logitech G HUB frequently encounters issues where:
- It fails to open on Windows startup unless launched manually as Administrator.
- It hangs infinitely on the Logitech logo animation.
- It displays permission errors when saving DPI / RGB lighting profiles.

### Root Causes
1. **Registry Flags**: Windows compatibility layers (`AppCompatFlags`) forcibly set `RUNASADMIN` on LG HUB executables.
2. **Locked AppData ACLs**: `%AppData%\LGHUB` permissions get assigned exclusively to the Administrator account.
3. **Stopped Updater Service**: `LGHUBUpdaterService` is stopped or set to manual, preventing the frontend UI from communicating with background device agents.

---

## 🚀 Usage Options / วิธีใช้งาน

### Option 1: Git Clone / GitHub CLI (100% Portable)
Clone the repository anywhere on Windows or WSL:

```bash
# On WSL Ubuntu
gh repo clone teay/logitech-ghub-fix
cd logitech-ghub-fix
./fix-ghub.sh
```

*(Optional: Run `./install.sh` inside WSL to register the `fix-ghub` command globally in your terminal).*

On Windows Command Prompt / PowerShell:
```powershell
git clone https://github.com/teay/logitech-ghub-fix.git
cd logitech-ghub-fix
.\Run-Fix.bat
```

---

### Option 2: Online One-Liner (PowerShell as Admin)
If you don't want to clone the repo, run directly from PowerShell:
```powershell
irm https://raw.githubusercontent.com/teay/logitech-ghub-fix/main/Fix-LGHUB.ps1 | iex
```

---

### Option 3: Double-Click Batch Launcher
1. Download or clone this repository anywhere on your PC.
2. Double-click `Run-Fix.bat` (It will automatically request Administrator elevation).

---

## ⚙️ What the Fix Script Does / สคริปต์แก้ไขอะไรบ้าง

| Step | Action | Description |
|---|---|---|
| 1 | **Kill LG HUB Processes** | Stops `lghub.exe`, `lghub_agent.exe`, `lghub_updater.exe`, `lghub_system_tray.exe` |
| 2 | **Clear AppCompatFlags** | Removes `RUNASADMIN` registry keys from `HKCU` and `HKLM` |
| 3 | **Enable Service** | Configures `LGHUBUpdaterService` startup type to `Automatic` and starts it |
| 4 | **Reset Permissions** | Grants `FullControl` to current user on `%AppData%\LGHUB` and `%LocalAppData%\LGHUB` |
| 5 | **Relaunch G HUB** | Starts `lghub.exe` in normal user security context |

---

## 🛠️ Repository Structure

```
logitech-ghub-fix/
├── Fix-LGHUB.ps1    # Portable PowerShell fix engine
├── Run-Fix.bat      # Windows batch launcher (relative paths)
├── fix-ghub.sh      # WSL Ubuntu portable launcher (dynamic wslpath)
├── install.sh       # WSL setup script (~/bin/fix-ghub)
├── README.md        # Documentation (English & Thai)
├── LICENSE          # MIT License
└── .gitignore
```

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
