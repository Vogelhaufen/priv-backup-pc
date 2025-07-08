## 🟥❗ CIG is enforcing EAC NOW. Huge script overhaul. ❗🟥

## Star Citizen Linux Launcher Script (Optimized for NVIDIA GPUs)

This script is intended to supplement the original `sc-launch.sh`

For installation and setup guidance, see:  
📎 [StarCitizen-LUG Quick Start Guide](https://github.com/starcitizen-lug/knowledge-base/wiki/Quick-Start-Guide)

---

## 🔧 Overview

```text
################################################################################
# Star Citizen Linux Launcher Script — NVIDIA GPU Optimization with DLSS v4
#
# Purpose:
#   Harness cutting-edge tech to supercharge Star Citizen on Linux with NVIDIA GPUs,
#   enabling DLSS v4 and seamless Wine integration.
#
#   Reality check: it’s mostly me duct-taping a bunch of scripts and tweaks together
#   so you don’t have to.
#
# Key Features:
#   • DLSS v4 integration
#   • Vulkan / Direct3D 11 Support
#   • Mactan Wine staging - optimized Wine Runner by the awesome community of LUG
#   • VRAM detection with dynamic limiting for system stability
#   • Wine patches fixing mouse cursor issues and infinite loading and much more!
#   • Streamlined Wine prefix and logging management
#
# Installation:
#   1. Place fetch.sh inside your Star Citizen Wine prefix directory
#      (typically $HOME/Games/star-citizen)
#   2. Make the script executable:
#        chmod +x fetch.sh
#   3. Launch the script:
#        ./fetch.sh
#   4. Start the game
#       ./startgame
#
# Important Notes:
#   • Requires a POSIX-compliant shell (bash, sh). Avoid incompatible shells like fish.
#   • May request sudo privileges to load kernel modules (ntsync).
#   • Achieves DLSS v4 functionality by patching system components and deploying
#     Wine DLL overrides.
#
# Additional Resources:
#   • Mactan Wine releases:
#     https://github.com/mactan-sc/mactan-sc-wine/releases/
#   • Star Citizen Linux Quick Start Guide:
#     https://github.com/starcitizen-lug/knowledge-base/wiki/Quick-Start-Guide
################################################################################
```

---

## ✅ Notes

- This script is optimized for **NVIDIA GPUs** under **Linux**
- You still need the original `sc-launch.sh`
- Latest 'DXVK' and 'DXVK/NVAPI' is **mandatory** but its applied automatically.
- Uses **Wine** and related utilities as described in the StarCitizen-LUG wiki
- Intended for advanced users who are familiar with Wine and Linux gaming setups
- This software is provided without any warranty or liability

---

## ❓ FAQ

**Q: The ingame DLSS debug overlay is showing DLSS Version 3?**  
**A:** It is an override. Version 310.x means you're on DLSS Version 4

**Q: My mouse is spinning/not clicking [...] ?**  
**A:** <a href="https://github.com/starcitizen-lug/knowledge-base/wiki/Troubleshooting#-unexpected-behavior-sometimes-also-crashes" target="_blank">Help</a> is here.

**Q: Why do i need to patch my libcuda.so and tinker with DLLs?**  
**A:** Here you go: <a href="https://github.com/jp7677/dxvk-nvapi/issues/174#issuecomment-2227462795" target="_blank">Thats</a> <a href="https://github.com/starcitizen-lug/knowledge-base/wiki/Troubleshooting#dlssdeep-learning-super-sampling--vulkan" target="_blank">Why</a>

**Q: How do i get rid of the DLSS debug overlay**  
**A:** Look for `export DXVK_NVAPI_SET_NGX_DEBUG_OPTIONS="DLSSIndicator=1024,DLSSGIndicator=2"` in `launchoptions.sh` to disable, set `DLSSIndicator=1,DLSSGIndicator=1`
The variables modify a registry value, which is why simply deleting them is not enough.

**Q: Do I need to install Proton or use Steam?**  
**A:** No. This script is designed for Wine. While Proton is Wine-based, this launcher uses a custom prefix with patched Wine builds optimized for Star Citizen.

**Q: Does this work with AMD GPUs?**  
**A:** It’s specifically optimized for NVIDIA cards due to DLSS integration. AMD users can still try the original `sc-launch.sh` but won’t benefit from DLSS.

**Q: What’s the advantage of this over Lutris or Heroic?**  
**A:** This launcher gives you full control over the Wine environment and applies patches for common struggles when using NVIDIA GPUs.

**Q: Where do I get `DXVK(/NVAPI)` and patched `libcuda.so`?**  
**A:** The script does it for you. Refer to the LUG Wiki for more information.

**Q:  Direct3D 11 or Vulkan?**  
**A:** Vulkan is considered beta. (Sometimes) it is crashing when tabbing out but its much smoother. Direct3D 11 is the stable choice!

---

## 📜 License

This script is shared for community use. Please credit the original contributors.  
All trademarks and game content belong to Cloud Imperium Games and their respective owners.

Check <a href="https://github.com/Vogelhaufen/priv-backup-pc/blob/main/sc-launch/COPYING.WTFPL" target="_blank">COPYING.WTFPL</a> for further Information.
---

## 💬 Support

For help, troubleshooting, and updates, visit the  
[StarCitizen-LUG GitHub Repository](https://github.com/starcitizen-lug)

Happy flying, citizen!
