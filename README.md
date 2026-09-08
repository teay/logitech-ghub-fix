นี่คือไฟล์ **README.md** ฉบับปรับปรุงแก้ไขล่าสุด (Updated Documentation) ที่อัปเดตข้อมูลโครงสร้างไฟล์ การตัดส่วนเกินออก และตรงตามพฤติกรรมของสคริปต์ใหม่ทั้งหมดครับ:

```markdown
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

### Option 1: Git Clone via WSL Ubuntu (Recommended)
Clone the repository anywhere on WSL to install and create a Windows Desktop launcher:

```bash
gh repo clone teay/logitech-ghub-fix
cd logitech-ghub-fix

# Install global 'fix-ghub' command & create 'Fix-GHUB.bat' on Windows Desktop
./install.sh

```

After running `./install.sh`, you can either:

* **On Windows:** Double-click `Fix-GHUB.bat` created on your Desktop.
* **On WSL:** Run `fix-ghub` or `./fix-ghub.sh` from anywhere in your terminal.

---

### Option 2: Online One-Liner (PowerShell as Admin)

If you don't want to clone the repo, run directly from PowerShell:

```powershell
irm [https://raw.githubusercontent.com/teay/logitech-ghub-fix/main/Fix-LGHUB.ps1](https://raw.githubusercontent.com/teay/logitech-ghub-fix/main/Fix-LGHUB.ps1) | iex

```

---

## 🧪 Automated Testing / การรันชุดทดสอบ

You can verify that all repair conditions are satisfied by running the test suite:

**On WSL Ubuntu:**

```bash
./test.sh

```

**On Windows PowerShell:**

```powershell
.\Test-FixLGHUB.ps1

```

---

## ⚙️ What the Fix Script Does / สคริปต์แก้ไขอะไรบ้าง

| Step | Action | Description |
| --- | --- | --- |
| 1 | **Kill LG HUB Processes** | Stops `lghub.exe`, `lghub_agent.exe`, `lghub_updater.exe`, `lghub_system_tray.exe` |
| 2 | **Clear AppCompatFlags** | Removes `RUNASADMIN` registry keys from `HKCU` and `HKLM` |
| 3 | **Enable Service** | Configures `LGHUBUpdaterService` startup type to `Automatic` and starts it |
| 4 | **Reset Permissions** | Grants `FullControl` to current user on `%AppData%\LGHUB` and `%LocalAppData%\LGHUB` |
| 5 | **Relaunch G HUB** | Starts `lghub.exe` in normal user security context |

---

## 🛠️ Repository Structure

```
logitech-ghub-fix/
├── Fix-LGHUB.ps1     # Portable PowerShell fix engine
├── Test-FixLGHUB.ps1 # Automated verification test suite
├── fix-ghub.sh       # WSL Ubuntu launcher
├── test.sh           # WSL test runner
├── install.sh        # WSL setup script (creates Windows Desktop launcher)
└── README.md         # Documentation

```

---

## 📄 License

This project is licensed under the [MIT License](https://www.google.com/search?q=LICENSE).

```