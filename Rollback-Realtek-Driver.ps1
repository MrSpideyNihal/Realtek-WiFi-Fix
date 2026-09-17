<#
.SYNOPSIS
    Realtek Wi-Fi Driver Rollback Script (6001.15.163.101 -> 6001.15.161.0)
.DESCRIPTION
    Removes the crashing May 2026 driver (6001.15.163.101) which triggers 
    NDIS 10317 and rtwlane601 Event 5002 fatal errors, and restores the stable 6001.15.161.0 driver.
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Requesting Administrator permissions..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "         Realtek Wi-Fi Driver Rollback & Repair Utility                     " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Deleting buggy driver version 6001.15.163.101 (oem2.inf)..." -ForegroundColor Yellow
pnputil /delete-driver oem2.inf /uninstall /force | Out-Null

Write-Host "[2/3] Installing stable driver version 6001.15.161.0..." -ForegroundColor Yellow
pnputil /add-driver "C:\Windows\System32\DriverStore\FileRepository\netrtwlane601.inf_amd64_47706e5e6ccfb9b9\netrtwlane601.inf" /install | Out-Null

Write-Host "[3/3] Preventing Windows Update driver overwrite..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "SearchOrderConfig" -Value 0 -Type DWord -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "                     DRIVER ROLLBACK COMPLETED!                             " -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Get-CimInstance -ClassName Win32_PnPSignedDriver | Where-Object { $_.DeviceName -like '*8852BE*' } | Select-Object DeviceName, DriverVersion, DriverDate
Write-Host ""
Write-Host "CRITICAL HARDWARE STEP FOR ASUS ROG/TUF LAPTOPS (EC RESET):" -ForegroundColor Red
Write-Host "  1. Shut down your laptop completely." -ForegroundColor White
Write-Host "  2. Unplug the charging cable." -ForegroundColor White
Write-Host "  3. Press and HOLD the POWER BUTTON for 40 SECONDS continuously." -ForegroundColor White
Write-Host "  4. Plug the charger back in and turn on the laptop." -ForegroundColor White
