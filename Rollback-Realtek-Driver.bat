@echo off
:: ============================================================================
:: Realtek Wi-Fi Driver Rollback Utility (6001.15.163.101 -> 6001.15.161.0)
:: Removes buggy oem2.inf driver causing NDIS 10317 & rtwlane601 Event 5002
:: ============================================================================

title Realtek Wi-Fi Driver Rollback Utility
color 0B

:: Self-elevation to Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator permissions...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

echo.
echo ============================================================================
echo         Realtek Wi-Fi Driver Rollback ^& Repair Utility
echo ============================================================================
echo.
echo [1/3] Deleting buggy driver version 6001.15.163.101 (oem2.inf)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "pnputil /delete-driver oem2.inf /uninstall /force" >nul 2>&1

echo [2/3] Installing stable driver version 6001.15.161.0...
pnputil /add-driver "C:\Windows\System32\DriverStore\FileRepository\netrtwlane601.inf_amd64_47706e5e6ccfb9b9\netrtwlane601.inf" /install >nul 2>&1

echo [3/3] Preventing Windows Update driver overwrite...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d 0 /f >nul 2>&1

echo.
echo ============================================================================
echo                     DRIVER ROLLBACK COMPLETED!
echo ============================================================================
echo.
echo Current Active Driver:
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance -ClassName Win32_PnPSignedDriver | Where-Object { $_.DeviceName -like '*8852BE*' } | Select-Object DeviceName, DriverVersion, DriverDate"

echo.
echo CRITICAL HARDWARE STEP FOR ASUS ROG/TUF LAPTOPS (EC RESET):
echo   1. Shut down your laptop completely.
echo   2. Unplug the charging cable.
echo   3. Press and HOLD the POWER BUTTON for 40 SECONDS continuously.
echo   4. Plug the charger back in and turn on the laptop.
echo.
pause
