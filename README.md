# Universal Realtek and MediaTek (MT7921 / MT7922) Wi-Fi and Bluetooth Disconnection Fix

Automated scripts to resolve recurring Wi-Fi disconnections, Bluetooth turning off, Code 10/43 errors, adapter disappearances, NDIS 10317 miniport crashes, and Kernel-PnP Event 420 ("Device deleted") issues on Realtek and MediaTek Wireless LAN PCI-E NICs.

## Supported Hardware

* MediaTek Wi-Fi 6 / 6E NICs: MediaTek MT7921, MT7922, AMD RZ608, RZ616
* Realtek Wi-Fi 6 / 6E NICs: Realtek 8852BE, 8852CE, 8822CE

## Problem Overview

On gaming laptops (such as ASUS ROG, ASUS TUF, Lenovo Legion, and HP Victus), MediaTek MT7921 and Realtek 8852BE cards suffer from two separate power-saving system bugs:

1. **PCIe Link State Dropouts (Kernel-PnP Event 420 / Code 10)**:
   Aggressive PCIe Link State Power Management (ASPM) cuts voltage to the M.2 Wi-Fi slot when idle or when Armoury Crate switches power profiles (Silent / Performance / Turbo). The MT7921 or 8852BE chip crashes and disappears from Device Manager.
2. **Bluetooth Disappearances (USB Selective Suspend)**:
   MediaTek MT7921 and Realtek cards are combo modules containing both Wi-Fi (PCIe) and Bluetooth (USB) on a single M.2 board. When Windows USB Selective Suspend triggers, the Bluetooth controller turns off completely.

## Fix Summary

This utility applies the following system and hardware power overrides:
1. Locks Wireless Adapter Power Saving to Maximum Performance across all power plans (AC & Battery).
2. Disables PCIe Link State Power Management (ASPM) across all power schemes (Silent, Performance, Turbo, Balanced).
3. Disables USB Selective Suspend to keep MediaTek MT7921 / Realtek Bluetooth active continuously.
4. Disables driver-level Roaming Aggressiveness drops, 802.11d channel scanning, and Leisure Power Save (LPS).
5. Disables Windows Fast Startup to prevent corrupted low-power state caching across reboots.

## Quick Start Guide

### Method 1: Universal 1-Click Fix (Recommended for MT7921 / 8852BE)

1. Download or clone this repository.
2. Right-click on `Fix-Realtek-WiFi.bat` and select **Run as Administrator**.
3. Follow the on-screen prompts and restart your computer when complete.

### Method 2: Driver Rollback (For Realtek 8852BE 6001.15.163.101 Miniport Crashes)

1. Right-click on `Rollback-Realtek-Driver.bat` and select **Run as Administrator**.
2. The script removes crashing driver `6001.15.163.101` and activates stable driver `6001.15.161.0`.
3. Perform a hardware EC Reset (Hold Power Button for 40 seconds while unplugged).

## License

MIT License. Free for personal and commercial use.
