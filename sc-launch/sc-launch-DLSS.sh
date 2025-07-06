#!/usr/bin/env bash
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

#--------------------------------------#
# CONFIGURATION & ENVIRONMENT SETUP    #
#--------------------------------------#

SC_LAUNCH_SCRIPT="sc-launch.sh"
ENVEXPORT_FILE="$PWD/ENVEXPORT"

echo "========== GPU Detection =========="
if ! lspci | grep -iq nvidia; then
  echo "✘ No NVIDIA graphics card found. Exiting."
  exit 1
fi
echo "✔ NVIDIA GPU detected."

echo "========== VRAM Limiting =========="
VRAM_LIMIT_MB=0
if command -v nvidia-smi > /dev/null; then
  VRAM_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n 1)
  VRAM_LIMIT_MB=$((VRAM_TOTAL - 1000))
  export VRAM_LIMIT_MB
  echo "✔ VRAM detected: ${VRAM_TOTAL} MiB. Limiting to ${VRAM_LIMIT_MB} MiB for Star Citizen."
else
  echo "⚠ nvidia-smi not found. VRAM detection failed."
fi
export DXVK_CONFIG="dxgi.maxDeviceMemory = $VRAM_LIMIT_MB;cachedDynamicResources = a;"

echo "========== Loading Wine Prefix =========="
if [ -f "$SC_LAUNCH_SCRIPT" ]; then
  grep "export WINEPREFIX" "$SC_LAUNCH_SCRIPT" > "$ENVEXPORT_FILE"
  if grep -q "WINEPREFIX" "$ENVEXPORT_FILE"; then
    . "$ENVEXPORT_FILE"
    echo "✔ WINEPREFIX loaded: $WINEPREFIX"
  else
    echo "✘ [ERROR] WINEPREFIX not found in $SC_LAUNCH_SCRIPT"
    exit 1
  fi
else
  echo "✘ [ERROR] $SC_LAUNCH_SCRIPT not found in $PWD"
  exit 1
fi
# --- Start DXVK and dxvk-nvapi update check and install ---

DXVK_VERSION_FILE="$WINEPREFIX/dxvk.version"
DXVK_NVAPI_VERSION_FILE="$WINEPREFIX/dxvk-nvapi.version"

DXVK_API_URL="https://api.github.com/repos/doitsujin/dxvk/releases/latest"
DXVK_NVAPI_API_URL="https://api.github.com/repos/jp7677/dxvk-nvapi/releases/latest"

# Helper: get latest release tag from GitHub API
get_latest_version() {
  curl -s "$1" | grep '"tag_name":' | head -n1 | sed -E 's/.*"([^"]+)".*/\1/'
}

# Check if all required DLLs exist for dxvk or dxvk-nvapi in system32 or syswow64
check_dlls_exist() {
  base_dir="$WINEPREFIX/drive_c/windows"
  if [ "$1" = "dxvk" ]; then
    dlls=(dxgi.dll d3d11.dll d3d10.dll)
  else
    dlls=(nvapi.dll nvapi64.dll)
  fi

  for dll in "${dlls[@]}"; do
    if [ ! -f "$base_dir/system32/$dll" ] && [ ! -f "$base_dir/syswow64/$dll" ]; then
      return 1
    fi
  done
  return 0
}

# Read installed versions
installed_dxvk_version=""
installed_dxvk_nvapi_version=""
[ -f "$DXVK_VERSION_FILE" ] && installed_dxvk_version=$(cat "$DXVK_VERSION_FILE")
[ -f "$DXVK_NVAPI_VERSION_FILE" ] && installed_dxvk_nvapi_version=$(cat "$DXVK_NVAPI_VERSION_FILE")

# Get latest versions
latest_dxvk_version=$(get_latest_version "$DXVK_API_URL")
latest_dxvk_nvapi_version=$(get_latest_version "$DXVK_NVAPI_API_URL")

# Decide if update needed
update_dxvk=0
update_dxvk_nvapi=0

check_dlls_exist "dxvk"
if [ "$installed_dxvk_version" != "$latest_dxvk_version" ] || [ $? -ne 0 ]; then
  update_dxvk=1
fi

check_dlls_exist "dxvk-nvapi"
if [ "$installed_dxvk_nvapi_version" != "$latest_dxvk_nvapi_version" ] || [ $? -ne 0 ]; then
  update_dxvk_nvapi=1
fi

# Download & install DXVK if update needed
if [ $update_dxvk -eq 1 ]; then
  echo "Updating DXVK to $latest_dxvk_version ..."
  tmpfile=$(mktemp /dxvk.blob.tar.gz)
  curl -L -o "$tmpfile" "https://github.com/doitsujin/dxvk/releases/download/$latest_dxvk_version/dxvk-$latest_dxvk_version.tar.gz"
  tar -xzf "$tmpfile" -C "$WINEPREFIX"
  # Copy DLLs to system32 and syswow64
  cp "$WINEPREFIX/dxvk-$latest_dxvk_version/x64/"*.dll "$WINEPREFIX/drive_c/windows/system32/"
  cp "$WINEPREFIX/dxvk-$latest_dxvk_version/x32/"*.dll "$WINEPREFIX/drive_c/windows/syswow64/"
  rm -rf "$WINEPREFIX/dxvk-$latest_dxvk_version"
  rm "$tmpfile"
  echo "$latest_dxvk_version" > "$DXVK_VERSION_FILE"
fi

# Download & install dxvk-nvapi if update needed
if [ $update_dxvk_nvapi -eq 1 ]; then
  echo "Updating dxvk-nvapi to $latest_dxvk_nvapi_version ..."
  tmpfile_nvapi=$(mktemp /dxvk-nvapi.blob.tar.gz)
  curl -L -o "$tmpfile_nvapi" "https://github.com/jp7677/dxvk-nvapi/releases/download/$latest_dxvk_nvapi_version/dxvk-nvapi-$latest_dxvk_nvapi_version.tar.gz"
  tar -xzf "$tmpfile_nvapi" -C "$WINEPREFIX"
  # Copy DLLs to system32 and syswow64
  cp "$WINEPREFIX/dxvk-nvapi-$latest_dxvk_nvapi_version/x64/"*.dll "$WINEPREFIX/drive_c/windows/system32/"
  cp "$WINEPREFIX/dxvk-nvapi-$latest_dxvk_nvapi_version/x32/"*.dll "$WINEPREFIX/drive_c/windows/syswow64/"
  rm -rf "$WINEPREFIX/dxvk-nvapi-$latest_dxvk_nvapi_version"
  rm "$tmpfile_nvapi"
  echo "$latest_dxvk_nvapi_version" > "$DXVK_NVAPI_VERSION_FILE"
fi

# --- End DXVK and dxvk-nvapi update check and install ---


# Download and extract Mactan Wine runner if not present
ARCHIVE_PATH="$PWD/runners/mactan103"
EXTRACT_DIR="$PWD/runners/wine-tkg-staging-ntsync-git-10.3.r4.gfa0cd8ea-327-x86_64"

echo "========== Mactan Wine Runner Setup =========="
if [ -d "$EXTRACT_DIR" ]; then
  echo "✔ Mactan runner already extracted, using existing files."
else
  if [ ! -f "$ARCHIVE_PATH" ]; then
    echo "⭳ Downloading Mactan runner..."
    wget -O "$ARCHIVE_PATH" https://github.com/mactan-sc/mactan-sc-wine/releases/download/10.3-git/wine-tkg-staging-ntsync-git-10.3.r4.gfa0cd8ea-327-x86_64.tar.gz
  else
    echo "✔ Archive already downloaded."
  fi
  echo "🗜 Extracting Mactan runner..."
  mkdir -p "$EXTRACT_DIR"
  tar xfz "$ARCHIVE_PATH" --directory="$EXTRACT_DIR/../"
fi

# Find the real 64-bit libcuda.so
echo "========== Locating 64-bit libcuda.so =========="

LIBCUDA_ORIG=""
LIB_SEARCH_PATHS=(
  /usr/lib
  /usr/lib64
  /usr/lib/x86_64-linux-gnu
  /lib
  /lib64
  /lib/x86_64-linux-gnu
  /usr/local/lib
  /usr/local/lib64
)

for dir in "${LIB_SEARCH_PATHS[@]}"; do
  for symlink in $(find "$dir" -type l -name "libcuda.so" 2>/dev/null); do
    resolved=$(realpath "$symlink")
    if [ -f "$resolved" ] && file "$resolved" | grep -q "ELF 64-bit"; then
      LIBCUDA_ORIG="$resolved"
      break 2
    fi
  done
done

if [ -z "$LIBCUDA_ORIG" ]; then
  echo "✘ No 64-bit libcuda.so found!"
  exit 1
else
  echo "✔ Found 64-bit libcuda.so at: $LIBCUDA_ORIG"
fi

# Patch libcuda.so for DLSSv4 support
PATCHED_LIB="$PWD/libcuda.patched.so"
HASHFILE="$HOME/.cache/libcuda.so.sha256"
mkdir -p "$(dirname "$HASHFILE")"
CURRENT_HASH=$(sha256sum "$LIBCUDA_ORIG" | cut -d ' ' -f 1)

if [ ! -f "$HASHFILE" ] || [ "$CURRENT_HASH" != "$(cat "$HASHFILE")" ] || [ ! -f "$PATCHED_LIB" ]; then
  echo "⚠ libcuda.so changed or patch missing. Applying patch..."
  echo -ne $(od -An -tx1 -v "$LIBCUDA_ORIG" | tr -d '\n' | sed -e 's/00 00 00 f8 ff 00 00 00/00 00 00 f8 ff ff 00 00/g' -e 's/ /\\x/g') > "$PATCHED_LIB"
  if [ $? -ne 0 ]; then
    echo "✘ [ERROR] Failed to patch libcuda.so!"
    exit 1
  fi
  echo "✔ libcuda.so patch applied."
  echo "$CURRENT_HASH" > "$HASHFILE"
else
  echo "✔ libcuda.so is already patched and up to date."
fi

# Setup fake DLLs for DLSS (only if not already existing)
echo "========== Setting up fake DLLs for DLSS =========="
FAKE_DLLS_DIR="$HOME/Games/star-citizen/drive_c/windows/system32/"
cd "$FAKE_DLLS_DIR" || { echo "✘ Failed to change directory to $FAKE_DLLS_DIR"; exit 1; }

for dll in cryptbase.dll devobject.dll drvstore.dll; do
  if [ -f "$dll" ]; then
    echo "✔ $dll already exists, skipping."
  else
    cp xaudio2_2.dll "$dll"
    echo "⭳ Created fake $dll"
  fi
done

# Export Wine-related environment variables
echo "========== Configuring Wine Environment =========="
launch_log="$WINEPREFIX/sc-launch.log"
export WINEDLLOVERRIDES="d3d10core,d3d11,d3d8,d3d9,dxgi,nvapi,nvapi64,nvofapi64=n;winemenubuilder="
export WINE_LARGE_ADDRESS_AWARE="1"
export WINEDEBUG=-all
# force NTSYNC, E/FSYNC fallback
export WINEESYNC
export WINEFSYNC

# disabled prompting for now. looks kinda sus 
echo "========== Loading ntsync kernel module =========="
if lsmod | grep -q ntsync; then
  echo "✔ ntsync already loaded."
else
  if sudo -n modprobe ntsync 2>/dev/null; then
    echo "✔ ntsync loaded without password prompt."
  else
    echo "✘ Failed to load ntsync without prompt."
    echo "Please run 'sudo modprobe ntsync' manually and re-run this script."
    exit 1
  fi
fi

# Proton / umu; no alien startscripts; not in use rn
export GAMEID=umu-starcitizen-noPreset-noProton
export STORE=none
# disable EAC
export EOS_USE_ANTICHEATCLIENTNULL=1
# libcuda.so
export LD_LIBRARY_PATH=$PATCHED_LIB
export LD_PRELOAD=$PATCHED_LIB
# DLSS Version 4
export PROTON_ENABLE_NGX_UPDATER=1
export DXVK_NVAPI_DRS_SETTINGS="NGX_DLSS_RR_OVERRIDE=on,NGX_DLSS_SR_OVERRIDE=on,NGX_DLSS_FG_OVERRIDE=on,NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest,NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest"
# Enable DLSS debug overlay in-game; to disable, set DLSSIndicator=1,DLSSGIndicator=1
export DXVK_NVAPI_SET_NGX_DEBUG_OPTIONS="DLSSIndicator=1024,DLSSGIndicator=2"
# NVIDIA related
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_SIZE=10737418240
export __GL_SHADER_DISK_CACHE_PATH="$WINEPREFIX"
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
export MESA_SHADER_CACHE_DIR="$WINEPREFIX"
export MESA_SHADER_CACHE_MAX_SIZE="10G"
export DXVK_HDR="1"
export DXVK_LOG_LEVEL="error"
export DXVK_NVAPIHACK="0"
export DXVK_ENABLE_NVAPI="1"
export PROTON_DXVK_D3D8="1"
# disable iGPUs
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus=NVIDIA_only
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json

# Optional HUDs
# export DXVK_HUD=fps
# export MANGOHUD=1

export wine_path="$WINEPREFIX/runners/wine-tkg-staging-ntsync-git-10.3.r4.gfa0cd8ea-327-x86_64/bin/"
export WINE_PATH="$wine_path"

echo "========== Paths used =========="
echo "WINEPREFIX dir: $WINEPREFIX"
echo "Wine runner bin dir: $wine_path"

case "$1" in
  "shell")
    echo "Entering Wine prefix maintenance shell. Type 'exit' when done."
    export PATH="$wine_path:$PATH"
    export PS1="Wine: "
    cd "$WINEPREFIX" || exit 1
    /usr/bin/env bash --norc
    exit 0
    ;;
  "config")
    /usr/bin/env bash --norc -c "${wine_path}/winecfg"
    exit 0
    ;;
  "controllers")
    /usr/bin/env bash --norc -c "${wine_path}/wine control joy.cpl"
    exit 0
    ;;
esac

update_check() {
  while "$wine_path"/winedbg --command "info proc" | grep -qi "rsi.*setup"; do
    sleep 2
  done
}
trap "update_check; \"$wine_path\"/wineserver -k" EXIT

echo "========== Launching Star Citizen =========="
"$wine_path"/wine "C:\\Program Files\\Roberts Space Industries\\RSI Launcher\\RSI Launcher.exe" --disable-gpu --in-process-gpu > "$launch_log" 2>&1
