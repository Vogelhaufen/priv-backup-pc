#!/usr/bin/env sh
################################################################################
# Star Citizen Launcher with DLSS4 and patched libcuda, using custom Wine build
# Includes automatic Wine runner download and patching guard
################################################################################

# --- Configurable paths ---
LIBCUDA_ORIG="/usr/lib/libcuda.so"
PATCHED_LIB="/tmp/libcuda.patched.so"
HASHFILE="$HOME/.cache/libcuda.so.sha256"

WINE_RUNNER_DIR="$PWD/runners/mactan103"
WINE_RUNNER_TAR="$PWD/runners/mactan103.tar.gz"
WINE_RUNNER_URL="https://github.com/mactan-sc/mactan-sc-wine/releases/download/10.3-git/wine-tkg-staging-ntsync-git-10.3.r4.gfa0cd8ea-327-x86_64.tar.gz"

WINEPREFIX="$HOME/Games/star-citizen"
wine_path="${wine_path:-$WINE_RUNNER_DIR/bin}"

# --- Patch libcuda.so only if hash changes ---
mkdir -p "$(dirname "$HASHFILE")"
CURRENT_HASH=$(sha256sum "$LIBCUDA_ORIG" | cut -d ' ' -f 1)

if [ ! -f "$HASHFILE" ] || [ "$CURRENT_HASH" != "$(cat "$HASHFILE")" ]; then
    echo "[INFO] libcuda.so changed or not yet patched. Patching now..."
    echo "Patching libcuda..."

    tr '\000' '\377' < "$LIBCUDA_ORIG" | \
    sed 's/\x48\x8d\x15\x00\x00\x00\x00/\x48\x8d\x15\xff\xff\xff\xff/g' > "$PATCHED_LIB"

    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to patch libcuda.so!"
        exit 1
    fi

    echo "Patching libcuda done"
    echo "$CURRENT_HASH" > "$HASHFILE"
else
    echo "[INFO] libcuda.so is already patched and up to date."
fi

# --- Ensure Wine runner exists or download it ---
if [ ! -d "$WINE_RUNNER_DIR" ]; then
    echo "[INFO] Wine runner not found. Downloading..."
    mkdir -p "$(dirname "$WINE_RUNNER_TAR")"
    wget -O "$WINE_RUNNER_TAR" "$WINE_RUNNER_URL"

    echo "[INFO] Extracting Wine runner..."
    tar -xf "$WINE_RUNNER_TAR" -C "$(dirname "$WINE_RUNNER_DIR")"
else
    echo "[INFO] Wine runner already present. Skipping download."
fi

# --- Load environment exports from main launcher script ---
grep "export" sc-launch.sh > "$PWD/ENVEXPORT"
. "$PWD/ENVEXPORT"

# --- Create fake DLLs required for launch ---
cd "$WINEPREFIX/drive_c/windows/system32/"
cp xaudio2_2.dll cryptbase.dll
cp xaudio2_2.dll devobject.dll
cp xaudio2_2.dll drvstore.dll

# --- Set Wine and DLSS-related environment variables ---
export WINEDLLOVERRIDES="d3d10core,d3d11,d3d8,d3d9,dxgi,nvapi,nvapi64,nvofapi64=n;winemenubuilder="
export WINE_LARGE_ADDRESS_AWARE="1"
export WINEDEBUG=-all
export WINEESYNC=1
export WINEFSYNC=1
export EOS_USE_ANTICHEATCLIENTNULL=1

export LD_LIBRARY_PATH="$(dirname "$PATCHED_LIB")"
export LD_PRELOAD="$PATCHED_LIB"

export PROTON_ENABLE_NGX_UPDATER=1
export DXVK_NVAPI_DRS_SETTINGS="NGX_DLSS_RR_OVERRIDE=on,NGX_DLSS_SR_OVERRIDE=on,NGX_DLSS_FG_OVERRIDE=on,NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest,NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest"
export DXVK_NVAPI_SET_NGX_DEBUG_OPTIONS="DLSSIndicator=1024,DLSSGIndicator=2"

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

# Optional: enable HUDs
# export DXVK_HUD=fps
# export MANGOHUD=1

# --- Load ntsync kernel module ---
echo "Please allow sudo to enable NTSYNC"
sudo modprobe ntsync

# --- Wine maintenance commands ---
case "$1" in
  shell)
    echo "Entering Wine prefix maintenance shell. Type 'exit' when done."
    export PATH="$wine_path:$PATH"
    export PS1="Wine: "
    cd "$WINEPREFIX" && /usr/bin/env bash --norc
    exit 0
    ;;
  config)
    /usr/bin/env bash --norc -c "${wine_path}/winecfg"
    exit 0
    ;;
  controllers)
    /usr/bin/env bash --norc -c "${wine_path}/wine control joy.cpl"
    exit 0
    ;;
esac

# --- Cleanup on exit + update check ---
update_check() {
  while "$wine_path"/winedbg --command "info proc" | grep -qi "rsi.*setup"; do
    sleep 2
  done
}
trap "update_check; \"$wine_path\"/wineserver -k" EXIT

# --- Launch the RSI Launcher (Star Citizen) ---
echo "Launching Star Citizen..."
"$wine_path"/wine "C:\\Program Files\\Roberts Space Industries\\RSI Launcher\\RSI Launcher.exe" \
  --disable-gpu --in-process-gpu > "$WINEPREFIX/sc-launch.log" 2>&1
