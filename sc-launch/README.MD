# Star Citizen Linux Launcher Script (Optimized for NVIDIA GPUs)

This script is intended to supplement the original `sc-launch.sh`

For installation and setup guidance, see:  
📎 [StarCitizen-LUG Quick Start Guide](https://github.com/starcitizen-lug/knowledge-base/wiki/Quick-Start-Guide)

---

## 🔧 Overview

```text
################################################################################
# Star Citizen Linux Launcher Script — NVIDIA GPU Optimization with DLSS Version4
#
# Purpose:
#   This script serves as a complementary launcher to the original sc-launch.sh,
#   specifically tailored to enhance Star Citizen performance on Linux systems
#   equipped with NVIDIA GPUs. It automates environment setup, applies critical
#   patches, and configures Wine for optimal compatibility and DLSS integration.
#
# Documentation:
#   For detailed usage instructions and troubleshooting, visit:
#   https://github.com/starcitizen-lug/knowledge-base/wiki/Quick-Start-Guide
#
# Features:
#   • Automatic installation of Mactan Wine 10.3 staging build
#   • VRAM detection and limiting to maintain system stability and performance
#   • Application of essential Wine patches including mouse cursor and loading fixes
#   • Deployment of fake DLLs to enable DLSS functionality
#   • Patching of libcuda.so to enable DLSS functionality
#   • Access to Wine shell, configuration, and controller setup utilities
#   • Automated management of Wine prefixes and logging for streamlined operation
################################################################################
```

---

## 📦 Installation Instructions

```text
################################################################################
# Installation Instructions:
#   1. Place this script inside your Star Citizen Wine prefix directory
#      typically located at $HOME/Games/star-citizen
#
#   2. Set executable permissions using
#        chmod +x sc-launch-DLSS.sh
#
#   3. Execute the script to launch Star Citizen
#        ./sc-launch-DLSS.sh
#
# Notes:
#   - This script requires a POSIX-compliant shell environment such as bash or sh.
#     Avoid shells such as fish that may not support necessary shell functions.
#   - Administrative privileges may be requested during execution for kernel module
#     loading and system-level operations.
################################################################################
```

---

## ✅ Notes

- This script is optimized for **NVIDIA GPUs** under **Linux**
- You still need the original `sc-launch.sh`
- Latest 'DXVK' and 'DXVK/NVAPI' is **mandatory**
- Uses **Wine** and related utilities as described in the StarCitizen-LUG wiki
- Intended for advanced users who are familiar with Wine and Linux gaming setups
- This software is provided without any warranty or liability

---

## 📂 File Info

- **Script Name:** sc-launch-DLSS.sh
- **Version:** It is a shellscript.

---

## 📜 License

This script is shared for community use. Please credit the original contributors.  
All trademarks and game content belong to Cloud Imperium Games and their respective owners.

---

## 💬 Support

For help, troubleshooting, and updates, visit the  
[StarCitizen-LUG GitHub Repository](https://github.com/starcitizen-lug)

Happy flying, citizen!
