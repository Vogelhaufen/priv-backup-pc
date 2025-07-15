## 🟥❗ This project has been deprecated due to changes by the LUG team, who are now implementing all the necessary steps to enable DLSS support in their Wine builds.❗🟥


## Star Citizen Linux Launcher Script (Optimized for NVIDIA GPUs)

This script is intended to supplement the original `sc-launch.sh`

---

## 🔧 Overview

```text
################################################################################
# Star Citizen Linux Launcher — NVIDIA GPU Optimization with DLSS v4
#
# Purpose:
#   Use cutting-edge tech to boost Star Citizen on Linux with NVIDIA GPUs,
#   enabling DLSS v4 and smooth Wine integration.
#
#   Reality check: mostly duct-taping scripts and tweaks so you don’t have to.
#
# Features:
#   • DLSS v4 support
#   • Vulkan & Direct3D 11
#   • Mactan Wine staging (optimized Wine runner by LUG community)
#   • VRAM detection with dynamic limits for stability
#   • Wine patches fixing mouse issues, infinite loading & more
#
# Notes:
#   • Requires POSIX shell (bash/sh), avoid fish
#   • May request sudo for kernel modules & libcuda mounting
#   • Implements DLSS v4 via system patches and Wine DLL overrides
#
# Resources:
#   • Mactan Wine: https://github.com/mactan-sc/mactan-sc-wine/releases/
#   • SC Linux Guide: https://github.com/starcitizen-lug/knowledge-base/wiki/Quick-Start-Guide
################################################################################
```

## 🔧 How to Install

Check <a href="https://github.com/Vogelhaufen/priv-backup-pc/blob/main/sc-launch/docs/INSTALL.MD" target="_blank">HOW TO INSTALL</a> for further Information.

---

## ✅ Notes

- This script is optimized for **NVIDIA GPUs** under **Linux**
- You still need the original `sc-launch.sh`
- Latest 'DXVK' and 'DXVK/NVAPI' is **mandatory** but its applied automatically.
- Uses **Wine** and related utilities as described in the StarCitizen-LUG wiki
- Intended for advanced users who are familiar with Wine and Linux gaming setups
- You most likely will get not support from the LUG-Helper community for this script since its very complex and hard to maintain
- It doesn't damage your LUG-Helper install - everything is untouched if you choose to remove it
- Doesn't seem to work on Fedora. Maybe SELinux? idk :)
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
**A:** Vulkan is considered beta and very experimental. Expect a lot of crashing on NVIDIA. Direct3D 11 is the stable choice!

**Q:  Why are we gaming in a sandbox?**  
**A:** Because EAC—Easy Anti-Cheat, or as some call it, “Extremely Annoying Code”—throws a fit the moment you try to breathe near a mod. Want better graphics with DLSS patches? Nope, EAC thinks you're plotting a world takeover. So we run the game in a sandbox—basically a digital playpen—where EAC can’t see us committing the heinous crime of trying to make our game look better. It's like tricking a mall cop with mirrored sunglasses. Everyone wins... except EAC, and honestly, I'm okay with that.

**Q:  My game is lagging!**  
**A:** Direct3D 11 needs like 15 minutes to finish shader caching. Vulkan needs a warmup on first start, after that its fine!

**Q:  I switched from Direct3D 11 to Vulkan. My game is crashing!**  
**A:** <a href="https://media.discordapp.net/attachments/549300875470962690/1392137013255344229/image.png?ex=686e7020&is=686d1ea0&hm=759bc45b6121af17370568bab272b00ebd1c00d4d985cc870f5c0a4a0264bf5c&=&format=webp&quality=lossless&width=1407&height=826" target="_blank">Clean your shaders.</a>

---

## 📜 License
Check <a href="https://github.com/Vogelhaufen/priv-backup-pc/blob/main/sc-launch/LICENSE" target="_blank">LICENSE</a> for further Information.
---

## 💬 Support

For help, troubleshooting, and updates, visit the  
[StarCitizen-LUG GitHub Repository](https://github.com/starcitizen-lug)
[StarCitizen-LUG Quick Start Guide](https://github.com/starcitizen-lug/knowledge-base/wiki/Quick-Start-Guide)

Happy flying, citizen!
