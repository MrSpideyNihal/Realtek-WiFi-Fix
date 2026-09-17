# Realtek Wi-Fi Disconnection, Driver Crash, and Power Drop Fix

Automated scripts to resolve recurring Wi-Fi disconnections, Code 10/43 errors, adapter disappearances, NDIS 10317 miniport crashes, and Kernel-PnP Event 420 ("Device deleted") issues on Realtek Wireless LAN PCI-E NICs (such as Realtek 8852BE, 8852CE, 8822CE).

## Problem Overview

On gaming laptops (such as ASUS ROG, ASUS TUF, and Lenovo Legion), two separate issues cause Realtek Wi-Fi disconnections:

1. **Driver Miniport Fatal Crashes (Event 5002 rtwlane601 / NDIS 10317)**:
   The May 2026 ASUS Realtek driver update (`6001.15.163.101`) contains a known memory deadlock bug that repeatedly crashes the NDIS miniport driver during operation.
2. **PCIe Power Link Dropouts (Kernel-PnP Event 420)**:
   Aggressive PCIe Link State Power Management (ASPM) cuts power to the Wi-Fi card when idle, causing Windows to report `Device deleted`.

## Tools Provided

* `Fix-Realtek-WiFi.bat`: Configures Windows power management, locks Wi-Fi power to Maximum Performance, turns off PCIe ASPM, and disables driver Leisure Power Save.
* `Rollback-Realtek-Driver.bat`: Force-deletes the buggy `6001.15.163.101` driver and restores the stable `6001.15.161.0` driver package.

## Quick Start Guide

### Step 1: Rollback Buggy Driver Version

1. Download or clone this repository.
2. Right-click on `Rollback-Realtek-Driver.bat` and select **Run as Administrator**.
3. The script will remove driver `6001.15.163.101` and activate stable driver `6001.15.161.0`.

### Step 2: Apply Power Management Fixes

1. Right-click on `Fix-Realtek-WiFi.bat` and select **Run as Administrator**.
2. Wait for the confirmation message.

### Step 3: Hardware EC Reset (Crucial for ASUS ROG/TUF Laptops)

1. Shut down your laptop completely.
2. Unplug the charging cable.
3. Press and HOLD the POWER BUTTON for 40 SECONDS continuously.
4. Plug the charger back in and turn on the laptop.

## Verification

After completing the steps above:
1. Open Device Manager -> **Network adapters** -> **Realtek 8852BE Wireless LAN WiFi 6 PCI-E NIC** -> Properties -> Driver tab.
2. Confirm Driver Version reads `6001.15.161.0`.

## License

MIT License. Free for personal and commercial use.
