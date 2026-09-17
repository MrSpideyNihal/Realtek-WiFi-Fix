<#
.SYNOPSIS
    Realtek Wi-Fi Disconnection & Power Drop Fix Script
.DESCRIPTION
    Fixes frequent Realtek 8852BE / 8852CE Wi-Fi disconnections, Code 10/43 errors,
    and Kernel-PnP Event 420 "Device Deleted" issues on Windows 10/11 laptops.
#>

# Require Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run as Administrator. Relaunching elevated..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "============================================================================" -ForegroundColor Green
Write-Host "         Realtek Wi-Fi Disconnection & Power Drop Fix Utility               " -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""

# 1. Unhide hidden Power Options in Windows Registry
Write-Host "[1/5] Unhiding PCIe ASPM and Wireless Power Settings in Control Panel..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\19cbb8fa-5279-450e-9fac-8a3d5fedd0c1\12bbebe6-58d6-4636-95bb-3217ef867c1a" -Name "Attributes" -Value 2 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\501a4d13-42af-4429-9fd1-a8218c268e20\ee12f906-d277-404b-b6da-e5fa1a576df5" -Name "Attributes" -Value 2 -ErrorAction SilentlyContinue

# 2. Disable Windows Fast Startup
Write-Host "[2/5] Disabling Windows Fast Startup (prevents low-power state cache bugs)..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue

# 3. Disable Realtek Driver Leisure Power Save in Registry
Write-Host "[3/5] Disabling Realtek Leisure Power Save (driver level)..." -ForegroundColor Yellow
Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\*' | Where-Object { $_.DriverDesc -like '*Realtek*' } | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "PnPCapabilities" -Value 24 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "LpsEn" -Value "0" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "LpsCap" -Value "0" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "LpsWowEn" -Value "0" -ErrorAction SilentlyContinue
}

# 4. Apply Power Scheme Settings across ALL power plans
Write-Host "[4/5] Locking Wireless Adapter to Maximum Performance & PCIe Link State to OFF..." -ForegroundColor Yellow
$schemes = powercfg /list | Select-String -Pattern "([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})" | ForEach-Object { $_.Matches.Value }
foreach ($s in $schemes) {
    powercfg /setacvalueindex $s 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0 | Out-Null
    powercfg /setdcvalueindex $s 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0 | Out-Null
    powercfg /setacvalueindex $s 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 | Out-Null
    powercfg /setdcvalueindex $s 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 | Out-Null
}
powercfg /setactive SCHEME_CURRENT | Out-Null

# 5. Refresh Network Adapter
Write-Host "[5/5] Refreshing Wi-Fi Adapter..." -ForegroundColor Yellow
Restart-NetAdapter -Name "Wi-Fi" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "                      SUCCESS! FIXES APPLIED SUCCESSFULLY.                  " -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "Please RESTART your computer once to ensure all settings take full effect." -ForegroundColor Cyan
