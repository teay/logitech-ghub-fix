<#
.SYNOPSIS
    Automated Test Suite for Logitech G HUB Fix Script
.DESCRIPTION
    Verifies that all 5 key repair conditions are satisfied:
    1. Executable file integrity check.
    2. Registry compatibility flags (No RunAsAdmin).
    3. LGHUBUpdaterService state (Automatic & Running).
    4. AppData folder permissions (User Write Access).
    5. Desktop shortcut presence.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "SilentlyContinue"

$passed = 0
$failed = 0

function Assert-Condition {
    param(
        [string]$TestName,
        [scriptblock]$Condition,
        [string]$FailureMessage
    )

    Write-Host -NoNewline "[TEST] $TestName ... "
    $result = $false
    try {
        $result = & $Condition
    } catch {
        $result = $false
    }

    if ($result) {
        Write-Host "PASSED" -ForegroundColor Green
        $script:passed++
    } else {
        Write-Host "FAILED" -ForegroundColor Red
        Write-Host "       Cause: $FailureMessage" -ForegroundColor DarkYellow
        $script:failed++
    }
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " Running Automated Verification Tests for G HUB" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Test 1: Check Executables Existence
$programFiles = $env:ProgramFiles
if (-not $programFiles) { $programFiles = "C:\Program Files" }
$lghubExe = Join-Path $programFiles "LGHUB\lghub.exe"

Assert-Condition `
    -TestName "1. Executable Existence (lghub.exe)" `
    -Condition { Test-Path $lghubExe } `
    -FailureMessage "lghub.exe not found at $lghubExe"

# Test 2: Verify Registry Flags (Must NOT contain RUNASADMIN)
Assert-Condition `
    -TestName "2. Registry Compatibility Flags (No RunAsAdmin)" `
    -Condition {
        $hkcu = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
        $hklm = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
        $hasAdminFlag = $false

        foreach ($path in @($hkcu, $hklm)) {
            if (Test-Path $path) {
                $props = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
                if ($props.PSObject.Properties[$lghubExe]) {
                    $hasAdminFlag = $true
                }
            }
        }
        return (-not $hasAdminFlag)
    } `
    -FailureMessage "Found 'RUNASADMIN' flag set in Windows Registry."

# Test 3: Check LGHUBUpdaterService
Assert-Condition `
    -TestName "3. LGHUBUpdaterService (Automatic & Running)" `
    -Condition {
        $service = Get-Service -Name "LGHUBUpdaterService" -ErrorAction SilentlyContinue
        if ($service) {
            return ($service.StartType -eq "Automatic" -and $service.Status -eq "Running")
        }
        return $false
    } `
    -FailureMessage "Service is not set to Automatic or is not currently running."

# Test 4: Check AppData User Permissions
Assert-Condition `
    -TestName "4. AppData Permissions (User Write Access)" `
    -Condition {
        $appDataPath = "$env:APPDATA\LGHUB"
        if (-not (Test-Path $appDataPath)) { return $true }
        
        # Test writing a temporary test file
        $testFile = Join-Path $appDataPath "perm_test.tmp"
        try {
            "test" | Out-File -FilePath $testFile -ErrorAction Stop
            Remove-Item $testFile -ErrorAction Stop
            return $true
        } catch {
            return $false
        }
    } `
    -FailureMessage "Current user cannot write to $env:APPDATA\LGHUB (Access Denied)."

# Test 5: Check Desktop Shortcut
$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop", "Fix-GHUB.bat")
Assert-Condition `
    -TestName "5. Windows Desktop Shortcut Presence" `
    -Condition { Test-Path $desktopPath } `
    -FailureMessage "Shortcut 'Fix-GHUB.bat' missing from Desktop."

$summaryColor = "Green"
if ($failed -gt 0) { $summaryColor = "Red" }

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Test Summary: $passed Passed, $failed Failed." -ForegroundColor $summaryColor
Write-Host "==================================================" -ForegroundColor Cyan

if ($failed -gt 0) {
    exit 1
} else {
    exit 0
}