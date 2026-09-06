<#
.SYNOPSIS
    Fixes Logitech G HUB "Run as Administrator" elevation requirements and infinite startup loading issues.

.DESCRIPTION
    Fully portable PowerShell repair script for Logitech G HUB:
    1. Terminates stuck LG HUB background processes.
    2. Clears 'RunAsAdmin' compatibility flags from Windows Registry (HKCU & HKLM).
    3. Configures LGHUBUpdaterService to Automatic startup and starts the service.
    4. Resets AppData folder permissions (ACLs) for current user.
    5. Creates Desktop shortcut 'Fix-Logitech-GHUB.bat' if missing.
    6. Relaunches Logitech G HUB in regular user context.

.EXAMPLE
    .\Fix-LGHUB.ps1
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

Write-Header "Logitech G HUB Auto-Fix Script (Portable)"

# Determine G HUB Installation Path Dynamically
$programFiles = $env:ProgramFiles
if (-not $programFiles) { $programFiles = "C:\Program Files" }

$lghubDir = Join-Path $programFiles "LGHUB"
$lghubExecutables = @(
    Join-Path $lghubDir "lghub.exe",
    Join-Path $lghubDir "lghub_agent.exe",
    Join-Path $lghubDir "lghub_updater.exe",
    Join-Path $lghubDir "lghub_system_tray.exe"
)

# 1. Terminate LG HUB Processes
Write-Step "1/6" "Terminating running Logitech G HUB processes..."
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
Write-Step "2/6" "Cleaning 'RunAsAdmin' registry compatibility flags..."
$regPaths = @(
    "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers",
    "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
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
Write-Step "3/6" "Checking LGHUBUpdaterService status..."
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
Write-Step "4/6" "Resetting user folder ACL permissions..."
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

# 5. Ensure Desktop Shortcut Exists
Write-Step "5/6" "Ensuring Windows Desktop shortcut exists..."
$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop", "Fix-Logitech-GHUB.bat")
if (-not (Test-Path $desktopPath)) {
    $batContent = @"
@echo off
title Fixing Logitech G HUB...
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/teay/logitech-ghub-fix/main/Fix-LGHUB.ps1 | iex"
timeout /t 3
"@
    Set-Content -Path $desktopPath -Value $batContent -Encoding ASCII -ErrorAction SilentlyContinue
    Write-Success "Created 'Fix-Logitech-GHUB.bat' shortcut on Windows Desktop."
} else {
    Write-Success "Desktop shortcut already exists."
}

# 6. Relaunch LG HUB
Write-Step "6/6" "Launching Logitech G HUB in standard user mode..."
$lghubPath = Join-Path $lghubDir "lghub.exe"
if (Test-Path $lghubPath) {
    Start-Process -FilePath $lghubPath
    Write-Success "Logitech G HUB launched successfully!"
} else {
    Write-Warn "Executable not found at location: $lghubPath"
}

Write-Header "Fix Complete! Check if G HUB opens normally."
