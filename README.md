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

## 🚀 Quick Start / วิธีใช้งาน

### Option 1: One-Liner (PowerShell)
Open PowerShell (as Administrator) and run:
```powershell
irm https://raw.githubusercontent.com/your-username/logitech-ghub-fix/main/Fix-LGHUB.ps1 | iex
```

### Option 2: Double-Click Batch File
1. Download or clone this repository.
2. Right-click `Run-Fix.bat` and select **Run as Administrator** (or double-click it).

### Option 3: Manual Execution
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Fix-LGHUB.ps1
```

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
├── Fix-LGHUB.ps1    # Main PowerShell fix script
├── Run-Fix.bat      # Batch launcher with UAC auto-elevation
├── README.md        # Documentation (English & Thai)
├── LICENSE          # MIT License
└── .gitignore
```

---

## 📄 License
This project is licensed under the [MIT License](LICENSE).
