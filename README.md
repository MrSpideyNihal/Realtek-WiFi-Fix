# Realtek Wi-Fi Disconnection and Power Drop Fix

Automated 1-click script to resolve recurring Wi-Fi disconnections, Code 10/43 errors, adapter disappearances, and Kernel-PnP Event 420 ("Device deleted") issues on Realtek Wireless LAN PCI-E NICs (such as Realtek 8852BE, 8852CE, 8822CE).

## Problem Overview

On many gaming laptops (such as ASUS ROG, ASUS TUF, and Lenovo Legion), Windows aggressive power management and PCIe Link State Power Management (ASPM) attempt to power down the Wi-Fi card when idle or in low power modes (e.g. Silent Mode).

When voltage drops, the Realtek hardware fails to maintain the PCIe link, causing:
* Kernel-PnP Event 420: `Device PCI\... was deleted`
* Device Manager Code 10 or Code 43 errors
* Wi-Fi card completely disappearing from Windows until a full cold reboot

## Fix Summary

This utility applies the following system and power configuration overrides:
1. Locks Wireless Adapter Power Saving to Maximum Performance across all power plans (AC & Battery).
2. Disables PCIe Link State Power Management (ASPM) across all power schemes.
3. Overrides driver-level Leisure Power Save (LPS) and PnPCapabilities registry settings.
4. Disables Windows Fast Startup to prevent corrupted low-power state caching across reboots.

## Quick Start Guide

### Method 1: Using the Batch Script (Recommended)

1. Download or clone this repository.
2. Right-click on `Fix-Realtek-WiFi.bat` and select **Run as Administrator**.
3. Follow the on-screen prompts and restart your computer when complete.

### Method 2: Using PowerShell

1. Open PowerShell as Administrator.
2. Run the following command:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Fix-Realtek-WiFi.ps1
```
3. Restart your computer when completed.

## Verification

After applying the script and restarting:
1. Open **Control Panel** -> **Power Options** -> **Change plan settings** -> **Change advanced power settings**.
2. Verify that **Wireless Adapter Settings** -> **Power Saving Mode** is set to **Maximum Performance**.
3. Verify that **PCI Express** -> **Link State Power Management** is set to **Off**.

## License

MIT License. Free for personal and commercial use.
