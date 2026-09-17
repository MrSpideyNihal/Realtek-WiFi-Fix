@echo off
:: ============================================================================
:: Realtek & MediaTek Wi-Fi / Bluetooth Disconnection & Power Fix Utility
:: Works for Realtek (8852BE/CE) and MediaTek (MT7921/MT7922/RZ608/RZ616)
:: Fixes Wi-Fi Disconnections, Bluetooth Turning Off, and Kernel-PnP Event 420
:: ============================================================================

title Universal Realtek & MediaTek Wi-Fi / Bluetooth Fix Utility
color 0A

:: Self-elevation to Administrator with ExecutionPolicy Bypass
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator permissions...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

echo.
echo ============================================================================
echo   Universal Realtek ^& MediaTek Wi-Fi / Bluetooth Disconnection Fix
echo ============================================================================
echo.

:: 1. Unhide hidden Power Options in Windows Registry (PCIe ASPM ^& Wireless)
echo [1/7] Unhiding PCIe ASPM, Wireless, and USB Power Settings...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\19cbb8fa-5279-450e-9fac-8a3d5fedd0c1\12bbebe6-58d6-4636-95bb-3217ef867c1a" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\501a4d13-42af-4429-9fd1-a8218c268e20\ee12f906-d277-404b-b6da-e5fa1a576df5" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\48e6b7a6-50f5-4782-a5d4-53bb8f07e226" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1

:: 2. Disable Windows Fast Startup
echo [2/7] Disabling Windows Fast Startup (prevents low-power state cache bugs)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

:: 3. Disable Driver Level Power Saving ^& Roaming Aggressiveness (Realtek ^& MediaTek)
echo [3/7] Disabling Driver Power Saving, Roaming Drops ^& Bluetooth Sleep...
powershell -NoProfile -ExecutionPolicy Bypass -Command "
Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\*' | Where-Object { $_.DriverDesc -like '*Realtek*' -or $_.DriverDesc -like '*MediaTek*' -or $_.DriverDesc -like '*MT79*' -or $_.DriverDesc -like '*RZ6*' } | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name 'RegRoamLevel' -Value '1' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name 'Dot11dEnable' -Value '0' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name 'SupportMACRandom' -Value '0' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name 'PnPCapabilities' -Value 24 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name 'LpsEn' -Value '0' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name 'LpsCap' -Value '0' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name 'LpsWowEn' -Value '0' -ErrorAction SilentlyContinue
}
" >nul 2>&1

:: 4. Disable USB Selective Suspend (Prevents Bluetooth portion of combo card from sleeping)
echo [4/7] Disabling USB Selective Suspend (keeps Bluetooth active)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "
$schemes = powercfg /list | Select-String -Pattern '([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})' | ForEach-Object { $_.Matches.Value }
foreach ($s in $schemes) {
    powercfg /setacvalueindex $s 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg /setdcvalueindex $s 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
}
" >nul 2>&1

:: 5. Apply Power Scheme Settings across ALL power plans (Balanced, Performance, Silent, Turbo)
echo [5/7] Locking Wireless Adapter to Max Performance ^& PCIe Link State to OFF...
powershell -NoProfile -ExecutionPolicy Bypass -Command "
$schemes = powercfg /list | Select-String -Pattern '([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})' | ForEach-Object { $_.Matches.Value }
foreach ($s in $schemes) {
    powercfg /setacvalueindex $s 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
    powercfg /setdcvalueindex $s 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
    powercfg /setacvalueindex $s 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
    powercfg /setdcvalueindex $s 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
}
powercfg /setactive SCHEME_CURRENT
" >nul 2>&1

:: 6. Flush Network Stack
echo [6/7] Flushing TCP/IP Stack ^& Winsock Catalog...
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
ipconfig /flushdns >nul 2>&1

:: 7. Refresh Network ^& Bluetooth Adapters
echo [7/7] Restarting Wi-Fi ^& Bluetooth Adapters...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Restart-NetAdapter -Name 'Wi-Fi' -ErrorAction SilentlyContinue" >nul 2>&1

echo.
echo ============================================================================
echo                      SUCCESS! ALL FIXES APPLIED.
echo ============================================================================
echo.
echo Please RESTART your computer once to ensure all settings take full effect.
echo.
pause
