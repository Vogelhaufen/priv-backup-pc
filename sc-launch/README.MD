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
