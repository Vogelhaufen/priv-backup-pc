# Star Citizen Linux Launcher Script (Optimized for NVIDIA GPUs)

This script is intended to supplement the original `sc-launch.sh`.

For installation and setup guidance, see:  
📎 [StarCitizen-LUG Quick Start Guide](https://github.com/starcitizen-lug/knowledge-base/wiki/Quick-Start-Guide)

---

## 🔧 Overview

```text
################################################################################
# Star Citizen Linux Launcher Script optimized for NVIDIA GPUs
# This script is intended to supplement the original sc-launch.sh
#
# https://github.com/starcitizen-lug/knowledge-base/wiki/Quick-Start-Guide
#
# Features:
# - Auto-installs Mactan wine 10.3 (staging build)
# - Detects and limits VRAM for performance
# - Applies Wine patches (mouse cursor fix, infinite loading fix)
# - Sets up fake DLLs for DLSS compatibility
# - Patches libcuda.so to enable DLSS
# - Provides Wine shell, config, and controller setup options
# - Auto-handles wine prefix management and logging
################################################################################
```

---

## 📦 Installation Instructions

```text
################################################################################
# Install:
# Download this script to your SC Prefix dir. 
# Default is $HOME/Games/star-citizen
#
# Make the script executable:
# chmod +x sc-launch-DLSSv4-version0.3.sh
# 
# Start the game:
# sh sc-launch-DLSS.sh
#
# You need a POSIX compliant shell! shells like fish destroy the patch function 
################################################################################
```

---

## ✅ Notes

- This script is optimized for **NVIDIA GPUs** under **Linux**
- Uses **Wine** and related utilities as described in the StarCitizen-LUG wiki
- Intended for advanced users who are familiar with Wine and Linux gaming setups
- This software is provided without any warranty or liability

---

## 📂 File Info

- **Script Name:** sc-launch-DLSS.sh
- **Version:** 0.3

---

## 📜 License

This script is shared for community use. Please credit the original contributors.  
All trademarks and game content belong to Cloud Imperium Games and their respective owners.

---

## 💬 Support

For help, troubleshooting, and updates, visit the  
[StarCitizen-LUG GitHub Repository](https://github.com/starcitizen-lug)

Happy flying, citizen!
