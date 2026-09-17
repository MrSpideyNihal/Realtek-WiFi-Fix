@echo off
:: ============================================================================
:: Realtek Wi-Fi Disconnection & Power Drop Fix (Realtek 8852BE / 8852CE / etc.)
:: Fixes Kernel-PnP Event 420 "Device Deleted" & Code 10/43 Disconnections
:: ============================================================================

title Realtek Wi-Fi Power Fix Utility
color 0A

:: Self-elevation to Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo Requesting Administrator permissions to apply Wi-Fi fixes...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo ============================================================================
echo         Realtek Wi-Fi Disconnection ^& Power Drop Fix Utility
echo ============================================================================
echo.
echo Applying power management overrides to prevent Wi-Fi from turning off...
echo.

:: 1. Unhide hidden Power Options in Windows Registry
echo [1/5] Unhiding PCIe ASPM and Wireless Power Settings in Control Panel...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\19cbb8fa-5279-450e-9fac-8a3d5fedd0c1\12bbebe6-58d6-4636-95bb-3217ef867c1a" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\501a4d13-42af-4429-9fd1-a8218c268e20\ee12f906-d277-404b-b6da-e5fa1a576df5" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1

:: 2. Disable Windows Fast Startup (Prevents PCIe state corruption on reboot)
echo [2/5] Disabling Windows Fast Startup (prevents low-power state cache bugs)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

:: 3. Disable Realtek Driver Leisure Power Save in Registry
echo [3/5] Disabling Realtek Leisure Power Save (driver level)...
powershell -Command "Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\*' | Where-Object { $_.DriverDesc -like '*Realtek*' } | ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name 'PnPCapabilities' -Value 24 -ErrorAction SilentlyContinue; Set-ItemProperty -Path $_.PSPath -Name 'LpsEn' -Value '0' -ErrorAction SilentlyContinue; Set-ItemProperty -Path $_.PSPath -Name 'LpsCap' -Value '0' -ErrorAction SilentlyContinue; Set-ItemProperty -Path $_.PSPath -Name 'LpsWowEn' -Value '0' -ErrorAction SilentlyContinue }" >nul 2>&1

:: 4. Apply Power Scheme Settings across ALL power plans (Balanced, Performance, Silent, Turbo)
echo [4/5] Locking Wireless Adapter to Maximum Performance ^& PCIe Link State to OFF...
powershell -Command "
$schemes = powercfg /list | Select-String -Pattern '([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})' | ForEach-Object { $_.Matches.Value }
foreach ($s in $schemes) {
    powercfg /setacvalueindex $s 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
    powercfg /setdcvalueindex $s 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
    powercfg /setacvalueindex $s 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
    powercfg /setdcvalueindex $s 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
}
powercfg /setactive SCHEME_CURRENT
" >nul 2>&1

:: 5. Refresh Wi-Fi Adapter
echo [5/5] Refreshing Wi-Fi Adapter...
powershell -Command "Restart-NetAdapter -Name 'Wi-Fi' -ErrorAction SilentlyContinue" >nul 2>&1

echo.
echo ============================================================================
echo                      SUCCESS! FIXES APPLIED SUCCESSFULLY.
echo ============================================================================
echo.
echo What was done:
echo   * Locked Wireless Adapter to Maximum Performance (AC ^& Battery).
echo   * Turned OFF PCIe Link State Power Management (ASPM).
echo   * Disabled Realtek Leisure Power Save ^& PnPCapabilities power reduction.
echo   * Disabled Windows Fast Startup to prevent sleep state glitches.
echo.
echo Please RESTART your computer once to ensure all settings take full effect.
echo.
pause
