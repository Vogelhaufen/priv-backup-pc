#!/usr/bin/env sh

################################################################################
# This script configures and launches Star Citizen FOR NVIDIA CARDS.
# This script configures and launches Star Citizen FOR NVIDIA CARDS.
# This script configures and launches Star Citizen FOR NVIDIA CARDS.
#
# The following .desktop files are added by wine during installation and then
# modified by the LUG Helper to call this script.
# They are automatically detected by most desktop environments for easy game
# launching.
#
#
################################################################################
# $HOME/Desktop/RSI Launcher.desktop
# $HOME/.local/share/applications/wine/Programs/Roberts Space Industries/RSI Launcher.desktop
################################################################################
#
# If you do not wish to use the above .desktop files, simply run this script
# from your terminal.
#
# version: 1.6
################################################################################

################################################################
# Configure the environment
# Add additional environment variables here as needed
################################################################

# Check if an NVIDIA graphics card is present
if lspci | grep -i nvidia > /dev/null; then
  echo "NVIDIA graphics card found."
else
  echo "No NVIDIA graphics card found. Exiting the script."
  exit 1
fi

# Continue with the rest of your script if NVIDIA is present


grep "export" sc-launch.sh > $PWD/ENVEXPORT
source $PWD/ENVEXPORT

#download mactan runner
#tar xfz $PWD/runners/mactan103 --directory=$PWD/runners $(wget -O $PWD/runners/mactan103 https://github.com/mactan-sc/mactan-sc-wine/releases/download/10.3-git/wine-tkg-staging-ntsync-git-10.3.r4.gfa0cd8ea-327-x86_64.tar.gz)
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
    tar xfz "$ARCHIVE_PATH" --directory="$EXTRACT_DIR"
fi



# --- Check if /usr/lib/libcuda.so changed and patch only if needed ---
LIBCUDA_ORIG="/usr/lib/libcuda.so"
PATCHED_LIB="$PWD/libcuda.patched.so"
HASHFILE="$HOME/.cache/libcuda.so.sha256"

mkdir -p "$(dirname "$HASHFILE")"
CURRENT_HASH=$(sha256sum "$LIBCUDA_ORIG" | cut -d ' ' -f 1)

if [ ! -f "$HASHFILE" ] || [ "$CURRENT_HASH" != "$(cat "$HASHFILE")" ]; then
    echo "libcuda.so changed or not yet patched. Patching now..."
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

#Create fake DLLs for DLSS
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

echo "Please allow sudo to enable NTSYNC"
sudo modprobe ntsync

#protonfoo / umu; no alien startscripts
export GAMEID=umu-starcitizen-noPreset-noProton
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
# gamescope --hdr-enabled -W 2560 -H 1440 --force-grab-cursor gamemoderun "$wine_path"/wine "C:\Program Files\Roberts Space Industries\RSI Launcher\RSI Launcher.exe" > "$launch_log" 2>&1

 "$wine_path"/wine "C:\Program Files\Roberts Space Industries\RSI Launcher\RSI Launcher.exe" --disable-gpu --in-process-gpu > "$launch_log" 2>&1
