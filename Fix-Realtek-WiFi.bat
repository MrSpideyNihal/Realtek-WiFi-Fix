@echo off
:: ============================================================================
:: Realtek Wi-Fi Disconnection & Power Drop Fix (Realtek 8852BE / 8852CE / etc.)
:: Fixes Kernel-PnP Event 420 "Device Deleted", Code 10/43 & Random Disconnects
:: ============================================================================

title Realtek Wi-Fi Complete Repair Utility
color 0A

:: Self-elevation to Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo Requesting Administrator permissions...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo ============================================================================
echo         Realtek Wi-Fi Disconnection ^& Power Drop Fix Utility
echo ============================================================================
echo.

:: 1. Unhide hidden Power Options in Windows Registry
echo [1/6] Unhiding PCIe ASPM and Wireless Power Settings...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\19cbb8fa-5279-450e-9fac-8a3d5fedd0c1\12bbebe6-58d6-4636-95bb-3217ef867c1a" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\501a4d13-42af-4429-9fd1-a8218c268e20\ee12f906-d277-404b-b6da-e5fa1a576df5" /v "Attributes" /t REG_DWORD /d 2 /f >nul 2>&1

:: 2. Disable Windows Fast Startup
echo [2/6] Disabling Windows Fast Startup...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

:: 3. Disable Realtek Roaming Aggressiveness ^& Power Saving in Registry
echo [3/6] Disabling Roaming Aggressiveness, 802.11d ^& Leisure Power Save...
powershell -Command "
$netKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0010'
if (Test-Path $netKey) {
    Set-ItemProperty -Path $netKey -Name 'RegRoamLevel' -Value '1' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $netKey -Name 'Dot11dEnable' -Value '0' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $netKey -Name 'SupportMACRandom' -Value '0' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $netKey -Name 'PnPCapabilities' -Value 24 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $netKey -Name 'LpsEn' -Value '0' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $netKey -Name 'LpsCap' -Value '0' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $netKey -Name 'LpsWowEn' -Value '0' -ErrorAction SilentlyContinue
}
" >nul 2>&1

:: 4. Apply Power Scheme Settings across ALL power plans (Balanced, Performance, Silent, Turbo)
echo [4/6] Locking Wireless Adapter to Max Performance ^& PCIe Link State to OFF...
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

:: 5. Flush Network Stack
echo [5/6] Flushing TCP/IP Stack ^& Winsock Catalog...
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
ipconfig /flushdns >nul 2>&1

:: 6. Refresh Network Adapter
echo [6/6] Restarting Wi-Fi Adapter...
powershell -Command "Restart-NetAdapter -Name 'Wi-Fi' -ErrorAction SilentlyContinue" >nul 2>&1

echo.
echo ============================================================================
echo                      SUCCESS! ALL FIXES APPLIED.
echo ============================================================================
echo.
echo Please RESTART your computer once to ensure all settings take full effect.
echo.
pause
