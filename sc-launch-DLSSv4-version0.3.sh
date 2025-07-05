#!/usr/bin/env sh

################################################################################
# This script configures and launches Star Citizen FOR NVIDIA CARDS.
#
# Downloads and installs Mactan WINE 10.3 staging which is recommended for best
# performance and also installs useful patches like fix mousepointer, fix infinite
# loading screen.
# 
# 
# Enables DLSS Version 4 and patches all required files when needed.
################################################################################

################################################################################
# Install:
# Download this script to your SC Prefix dir. 
# Default is $HOME/Games/star-citizen
# Make the script executable:
# chmod +x sc-launch-DLSSv4-version0.3.sh
# 
# Start the game:
# sh sc-launch-DLSSv4-version0.3.sh
#
# You need a POSIX compliant shell! shells like fish destroy the patch function 
################################################################################

################################################################
# Configure the environment
# Add additional environment variables here as needed
################################################################

# Check if an NVIDIA graphics card is present otherwise stop
if lspci | grep -i nvidia > /dev/null; then
  echo "!"
else
  echo "No NVIDIA graphics card found. Exiting the script."
  exit 1
fi

# Default to no GPU
VRAM_MB_MINUS_1000=0

# fix for framedrops
# Check if an NVIDIA graphics card is present and set VRAM amount to limit memory avaible to SC
# https://github.com/starcitizen-lug/knowledge-base/wiki/Troubleshooting#severe-frame-drops
if lspci | grep -i nvidia > /dev/null; then
    echo "NVIDIA GPU detected. Checking for VRAM MAX"

    # Check if nvidia-smi is available
    if command -v nvidia-smi > /dev/null; then
        # Get VRAM in MiB (first GPU only)
        VRAM_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n 1)

        # Subtract 1000 MiB
        VRAM_MB_MINUS_1000=$((VRAM_TOTAL - 1000))

        # Export the variable
        export VRAM_MB_MINUS_1000
        echo "VRAM_MB_MINUS_1000=$VRAM_MB_MINUS_1000"
        echo "Limiting VRAM avaible to SC to $VRAM_MB_MINUS_1000 MiB"
    else
        echo "nvidia-smi not found. Cannot determine VRAM."
    fi
else
    echo "No NVIDIA GPU detected."
fi

export DXVK_CONFIG="dxgi.maxDeviceMemory = $VRAM_MB_MINUS_1000;cachedDynamicResources = a;"




# Continue if NVIDIA is present
# Lets find our WINEPREFIX dir
# sourcing is used for future ENV imports

grep "export WINEPREFIX" sc-launch.sh > $PWD/ENVEXPORT
source $PWD/ENVEXPORT
echo "sourcing WINEPREFIX from sc-launch.sh:"
echo "$WINEPREFIX"

#justfordebug
#removeme
#snapshotver=1.9
#export WINEPREFIX="/home/hans/Games/star-citizen-xdd20252nd"

# Download and extract mactan runner only if not already done
ARCHIVE_PATH="$PWD/runners/mactan103"
EXTRACT_DIR="$PWD/runners/wine-tkg-staging-ntsync-git-10.3.r4.gfa0cd8ea-327-x86_64"
if [ -d "$EXTRACT_DIR" ]; then
    echo "Mactan runner already extracted, using existing files."
else
    if [ ! -f "$ARCHIVE_PATH" ]; then
        echo "Downloading mactan runner..."
        wget -O "$ARCHIVE_PATH" https://github.com/mactan-sc/mactan-sc-wine/releases/download/10.3-git/wine-tkg-staging-ntsync-git-10.3.r4.gfa0cd8ea-327-x86_64.tar.gz
    else
        echo "Archive already downloaded."
    fi

    echo "Extracting mactan runner..."
    mkdir -p "$EXTRACT_DIR"
    tar xfz "$ARCHIVE_PATH" --directory="$EXTRACT_DIR/../"
fi



# Check if /usr/lib/libcuda.so changed and patch only if needed
# https://github.com/starcitizen-lug/knowledge-base/wiki/Troubleshooting#dlssdeep-learning-super-sampling--vulkan
# delete $HOME/.cache/libcuda.so.sha256 to apply the patch again
LIBCUDA_ORIG="/usr/lib/libcuda.so"
PATCHED_LIB="$PWD/libcuda.patched.so"
HASHFILE="$HOME/.cache/libcuda.so.sha256"

mkdir -p "$(dirname "$HASHFILE")"
CURRENT_HASH=$(sha256sum "$LIBCUDA_ORIG" | cut -d ' ' -f 1)

if [ ! -f "$HASHFILE" ] || [ "$CURRENT_HASH" != "$(cat "$HASHFILE")" ] || [ ! -f "$PATCHED_LIB" ]; then
    echo "libcuda.so changed, not yet patched, or patched version missing. Patching now..."
    echo -ne $(od -An -tx1 -v "$LIBCUDA_ORIG" | tr -d '\n' | sed -e 's/00 00 00 f8 ff 00 00 00/00 00 00 f8 ff ff 00 00/g' -e 's/ /\\x/g') > "$PATCHED_LIB"
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to patch libcuda.so!"
        exit 1
    fi
    echo "Patching libcuda done"
    echo "$CURRENT_HASH" > "$HASHFILE"
else
    echo "libcuda.so is already patched and up to date."
fi

#might not be needed. removed:
#echo !!!Change SC Launcher Game Dir to $(echo "Z:$(realpath "$HOME/Games/star-citizen/drive_c/Program Files/Roberts Space Industries")" | sed -e 's/\//\\/g')
#export WINEPREFIX="/home/hans/Games/star-citizen-xdd20252nd"


#Create fake DLLs for DLSS
echo "Fake DLL Setup for DLSS"
cd $HOME/Games/star-citizen/drive_c/windows/system32/
cp xaudio2_2.dll cryptbase.dll
cp xaudio2_2.dll devobject.dll
cp xaudio2_2.dll drvstore.dll


launch_log="$WINEPREFIX/sc-launch.log"
export WINEDLLOVERRIDES="d3d10core,d3d11,d3d8,d3d9,dxgi,nvapi,nvapi64,nvofapi64=n;winemenubuilder="
export WINE_LARGE_ADDRESS_AWARE="1"
export WINEDEBUG=-all # Cut down on console debug messages

#force NTSYNC; fallback E/FSYNC
export WINEESYNC
export WINEFSYNC
echo ""
echo "##################################"
echo "Please allow sudo to enable NTSYNC"
echo "##################################"
echo ""
sudo modprobe ntsync

#protonfoo / umu; no alien startscripts
export GAMEID=umu-starcitizen-noPreset-noProton
export STORE=none
#disable EAC
export EOS_USE_ANTICHEATCLIENTNULL=1
#Patched cuda
export LD_LIBRARY_PATH=$PATCHED_LIB
export LD_PRELOAD=$PATCHED_LIB 
#DLSSv4
export PROTON_ENABLE_NGX_UPDATER=1 
export DXVK_NVAPI_DRS_SETTINGS=NGX_DLSS_RR_OVERRIDE=on,NGX_DLSS_SR_OVERRIDE=on,NGX_DLSS_FG_OVERRIDE=on,NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest,NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest
#show DLSSv4 debug info overlay ingame. to disable set both ENVs to 1
export DXVK_NVAPI_SET_NGX_DEBUG_OPTIONS=DLSSIndicator=1024,DLSSGIndicator=2
# Nvidia cache options
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_SIZE=10737418240
export __GL_SHADER_DISK_CACHE_PATH="$WINEPREFIX"
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
# Mesa (AMD/Intel) shader cache options
export MESA_SHADER_CACHE_DIR="$WINEPREFIX"
export MESA_SHADER_CACHE_MAX_SIZE="10G"
#NVIDIA custom
export DXVK_HDR="1"
export DXVK_LOG_LEVEL="error"
export DXVK_NVAPIHACK="0"
export DXVK_ENABLE_NVAPI="1"
export PROTON_DXVK_D3D8="1"

# Optional HUDs
#export DXVK_HUD=fps,export WINEARCH="win64" compiler
#export MANGOHUD=1

################################################################
# Configure the wine binaries to be used
#
# To use a custom wine runner, set the path to its bin directory
# export wine_path="/path/to/custom/runner/bin"
################################################################
export wine_path=$WINEPREFIX/runners/wine-tkg-staging-ntsync-git-10.3.r4.gfa0cd8ea-327-x86_64/bin/
export WINE_PATH=$WINEPREFIX/runners/wine-tkg-staging-ntsync-git-10.3.r4.gfa0cd8ea-327-x86_64/bin/
echo "Paths used:"
echo "WINEPREFIX dir: $WINEPREFIX"
echo "wine_path dir: $wine_path"

#############################################
# Command line arguments
#############################################
# shell - Drop into a Wine maintenance shell
# config - Wine configuration
# controllers - Game controller configuration
# Usage: ./sc-launch.sh shell
case "$1" in
    "shell")
        echo "Entering Wine prefix maintenance shell. Type 'exit' when done."
        export PATH="$wine_path:$PATH"; export PS1="Wine: "
        cd "$WINEPREFIX"; pwd; /usr/bin/env bash --norc; exit 0
        ;;
    "config")
        /usr/bin/env bash --norc -c "${wine_path}/winecfg"; exit 0
        ;;
    "controllers")
        /usr/bin/env bash --norc -c "${wine_path}/wine control joy.cpl"; exit 0
        ;;
esac

#############################################
# Run optional prelaunch and postexit scripts
#############################################
# To use, update the game install paths here, create the scripts with your
# desired actions in them, then place them in your prefix directory:
# sc-prelaunch.sh and sc-postexit.sh
# Replace the trap line in the section below with the example provided here
#
# "$WINEPREFIX/sc-prelaunch.sh"
# trap "update_check; \"$wine_path\"/wineserver -k; \"$WINEPREFIX\"/sc-postexit.sh" EXIT

#############################################
# It's a trap!
#############################################
# Kill the wine prefix when this script exits
# This makes sure there will be no lingering background wine processes
update_check() {
    while "$wine_path"/winedbg --command "info proc" | grep -qi "rsi.*setup"; do
        sleep 2
    done
}
trap "update_check; \"$wine_path\"/wineserver -k" EXIT

#############################################
# Launch the game
#############################################
# To enable feral gamemode, replace the launch line below with:
# gamemoderun "$wine_path"/wine "C:\Program Files\Roberts Space Industries\RSI Launcher\RSI Launcher.exe" > "$launch_log" 2>&1
#
# To enable gamescope and feral gamemode, replace the launch line below with the
# desired gamescope arguments. For example:
 "$wine_path"/wine "C:\Program Files\Roberts Space Industries\RSI Launcher\RSI Launcher.exe" --disable-gpu --in-process-gpu > "$launch_log" 2>&1
