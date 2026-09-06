<#
.SYNOPSIS
    Fixes Logitech G HUB "Run as Administrator" elevation requirements and infinite startup loading issues.

.DESCRIPTION
    Logitech G HUB often gets stuck on startup or fails to open unless launched as Administrator.
    This script automates the full repair procedure:
    1. Terminates stuck LG HUB background processes.
    2. Clears 'RunAsAdmin' compatibility flags from Windows Registry (HKCU & HKLM).
    3. Configures LGHUBUpdaterService to Automatic startup and starts the service.
    4. Resets AppData folder permissions (ACLs) for current user.
    5. Relaunches Logitech G HUB in regular user context.

.EXAMPLE
    .\Fix-LGHUB.ps1

.LINK
    https://github.com/your-username/logitech-ghub-fix
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "SilentlyContinue"

function Write-Header {
    param([string]$Message)
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host " $Message" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
}

function Write-Step {
    param([string]$StepNumber, [string]$Message)
    Write-Host "[$StepNumber] $Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [+] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [!] $Message" -ForegroundColor DarkYellow
}

Write-Header "Logitech G HUB Auto-Fix Script"

# 1. Terminate LG HUB Processes
Write-Step "1/5" "Terminating running Logitech G HUB processes..."
$processes = @("lghub", "lghub_agent", "lghub_updater", "lghub_system_tray")
foreach ($proc in $processes) {
    $running = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($running) {
        Write-Warn "Stopping $proc (ID: $($running.Id -join ', '))..."
        Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
    }
}
Write-Success "All G HUB processes stopped."

# 2. Clear Registry AppCompatFlags
Write-Step "2/5" "Cleaning 'RunAsAdmin' registry compatibility flags..."
$regPaths = @(
    "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers",
    "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
)

$lghubExecutables = @(
    "C:\Program Files\LGHUB\lghub.exe",
    "C:\Program Files\LGHUB\lghub_agent.exe",
    "C:\Program Files\LGHUB\lghub_updater.exe",
    "C:\Program Files\LGHUB\lghub_system_tray.exe"
)

$flagsRemoved = 0
foreach ($regPath in $regPaths) {
    if (Test-Path $regPath) {
        $props = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
        if ($props) {
            foreach ($exe in $lghubExecutables) {
                if ($props.PSObject.Properties[$exe]) {
                    Write-Warn "Removing RunAsAdmin flag for: $exe in $regPath"
                    Remove-ItemProperty -Path $regPath -Name $exe -ErrorAction SilentlyContinue
                    $flagsRemoved++
                }
            }
        }
    }
}
if ($flagsRemoved -eq 0) {
    Write-Success "No elevated registry flags were found."
} else {
    Write-Success "Successfully removed $flagsRemoved registry compatibility flag(s)."
}

# 3. Configure and Start LGHUBUpdaterService
Write-Step "3/5" "Checking LGHUBUpdaterService status..."
$service = Get-Service -Name "LGHUBUpdaterService" -ErrorAction SilentlyContinue
if ($service) {
    Write-Success "Found LGHUBUpdaterService. Ensuring StartupType is Automatic..."
    Set-Service -Name "LGHUBUpdaterService" -StartupType Automatic -ErrorAction SilentlyContinue
    if ($service.Status -ne "Running") {
        Write-Success "Starting LGHUBUpdaterService..."
        Start-Service -Name "LGHUBUpdaterService" -ErrorAction SilentlyContinue
    } else {
        Write-Success "LGHUBUpdaterService is already running."
    }
} else {
    Write-Warn "LGHUBUpdaterService not detected on this system."
}

# 4. Reset AppData Permissions
Write-Step "4/5" "Resetting user folder ACL permissions..."
$appDataPaths = @(
    "$env:APPDATA\LGHUB",
    "$env:LOCALAPPDATA\LGHUB"
)

foreach ($path in $appDataPaths) {
    if (Test-Path $path) {
        Write-Success "Granting Full Control to ${env:USERNAME} on $path"
        icacls "$path" /grant "${env:USERNAME}:(OI)(CI)F" /T /Q /C | Out-Null
    }
}

# 5. Relaunch LG HUB
Write-Step "5/5" "Launching Logitech G HUB in standard user mode..."
$lghubPath = "C:\Program Files\LGHUB\lghub.exe"
if (Test-Path $lghubPath) {
    Start-Process -FilePath $lghubPath
    Write-Success "Logitech G HUB launched successfully!"
} else {
    Write-Warn "Executable not found at default location: $lghubPath"
}

Write-Header "Fix Complete! Check if G HUB opens normally."
