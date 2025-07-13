#!/usr/bin/env bash
#--------------------------------------#
# CONFIGURATION & ENVIRONMENT SETUP    #
#--------------------------------------#

SC_LAUNCH_SCRIPT="sc-launch.sh"
ENVEXPORT_FILE="$PWD/ENVEXPORT"

echo "=================== GPU Detection ==================="
if ! lspci | grep -iq nvidia; then
  echo "✘ No NVIDIA graphics card found. Exiting."
  exit 1
fi
echo "✔ NVIDIA GPU detected."


echo "=================== VRAM Limiting ==================="
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


echo "================ Loading Wine Prefix =================="
if [ -f "$SC_LAUNCH_SCRIPT" ]; then
  grep "export WINEPREFIX" "$SC_LAUNCH_SCRIPT" > "$ENVEXPORT_FILE"
  if grep -q "WINEPREFIX" "$ENVEXPORT_FILE"; then
    . "$ENVEXPORT_FILE"
    echo "✔ WINEPREFIX loaded: $WINEPREFIX"
  else
    echo "✘ [ERROR] WINEPREFIX not found in $SC_LAUNCH_SCRIPT"
    echo "Using default WINEPREFIX=$HOME/Games/star-citizen"
    export WINEPREFIX=$HOME/Games/star-citizen
  fi
else
  echo "✘ [ERROR] $SC_LAUNCH_SCRIPT not found in $PWD"
  exit 1
fi

echo "========== Checking DXVK and DXVK/NVAPI DLLs =========="
# Hardcoded VERSION for downgrades
DXVK_VERSION="2.7" 
DXVK_NVAPI_VERSION="0.9.0"

DXVK_URL="https://github.com/doitsujin/dxvk/releases/download/v${DXVK_VERSION}/dxvk-${DXVK_VERSION}.tar.gz"
DXVK_NVAPI_URL="https://github.com/jp7677/dxvk-nvapi/releases/download/v${DXVK_NVAPI_VERSION}/dxvk-nvapi-v${DXVK_NVAPI_VERSION}.tar.gz"

VERSION_FILE="$WINEPREFIX/.dxvk_versions"

download_and_extract() {
    url="$1"
    dest="$2"
    archive="${TMPDIR}/archive.tar.gz"

    printf "Downloading from %s ...\n" "$url"
    curl -sSL "$url" -o "$archive"

    # Verify if the downloaded file is a valid gzip archive
    if ! file "$archive" | grep -q 'gzip compressed data'; then
        printf "✘ Error: Invalid archive downloaded from %s\n" "$url"
        rm -rf "$TMPDIR"
        exit 1
    fi

    mkdir -p "$dest"
    # Extract the archive, stripping the top-level folder
    tar -xzf "$archive" -C "$dest" --strip-components=1
}

check_dxvk_versions() {
  if [ -f "$VERSION_FILE" ]; then
    saved_dxvk_version=$(grep "^DXVK=" "$VERSION_FILE" | cut -d= -f2)
    saved_nvapi_version=$(grep "^NVAPI=" "$VERSION_FILE" | cut -d= -f2)
    if [ "$saved_dxvk_version" = "$DXVK_VERSION" ] && [ "$saved_nvapi_version" = "$DXVK_NVAPI_VERSION" ]; then
      return 0
    fi
  fi
  return 1
}

if check_dxvk_versions; then
  printf "✔ DXVK and dxvk-nvapi version %s / %s already installed. Skipping download.\n" "$DXVK_VERSION" "$DXVK_NVAPI_VERSION"
else
  TMPDIR=$(mktemp -d) || exit 1

  printf "Updating DXVK to v%s ...\n" "$DXVK_VERSION"
  download_and_extract "$DXVK_URL" "${TMPDIR}/dxvk"

  printf "Copying DXVK files to Wine prefix...\n"
  cp -f "${TMPDIR}/dxvk/x64/"*.dll "${WINEPREFIX}/drive_c/windows/system32/"
  cp -f "${TMPDIR}/dxvk/x32/"*.dll "${WINEPREFIX}/drive_c/windows/syswow64/"

  printf "Updating dxvk-nvapi to v%s ...\n" "$DXVK_NVAPI_VERSION"
  download_and_extract "$DXVK_NVAPI_URL" "${TMPDIR}/dxvk-nvapi"

  printf "Copying dxvk-nvapi files to Wine prefix...\n"
  cp -f "${TMPDIR}/dxvk-nvapi/x64/"*.dll "${WINEPREFIX}/drive_c/windows/system32/"
  cp -f "${TMPDIR}/dxvk-nvapi/x32/"*.dll "${WINEPREFIX}/drive_c/windows/syswow64/"

  rm -rf "$TMPDIR"
  printf "Update completed.\n"

  # Save installed versions
  printf "DXVK=%s\nNVAPI=%s\n" "$DXVK_VERSION" "$DXVK_NVAPI_VERSION" > "$VERSION_FILE"
fi


echo "============= Mactan Wine Runner Setup ==============="

declare -A WINE_VERSIONS=(
  ["10.10-git"]="https://github.com/mactan-sc/mactan-sc-wine/releases/download/10.10-git/wine-tkg-staging-ntsync-git-10.10.tar.gz"
  ["10.8-git"]="https://github.com/mactan-sc/mactan-sc-wine/releases/download/10.8-git/wine-tkg-staging-ntsync-git-10.8.tar.gz"
  ["10.7-git"]="https://github.com/mactan-sc/mactan-sc-wine/releases/download/10.7-git/wine-tkg-staging-ntsync-git-10.7.r0.gedfe4935-327-x86_64.tar.gz"
  ["10.6-git"]="https://github.com/mactan-sc/mactan-sc-wine/releases/download/10.6-git/wine-tkg-staging-ntsync-git-10.6.r0.g81425de3-327-x86_64.tar.gz"
  ["10.3-git"]="https://github.com/mactan-sc/mactan-sc-wine/releases/download/10.3-git/wine-tkg-staging-ntsync-git-10.3.r4.gfa0cd8ea-327-x86_64.tar.gz"
)

BASE_DIR="$PWD/runners"
EXTRACT_DIR="$BASE_DIR/wine_runner"
CONFIG_FILE="$BASE_DIR/.mactan_wine_version"
DEFAULT_VERSION="10.10-git"

mkdir -p "$BASE_DIR"

if [ -f "$CONFIG_FILE" ]; then
  VERSION=$(cat "$CONFIG_FILE")
  if [[ ! ${WINE_VERSIONS[$VERSION]+_} ]]; then
    echo "Saved version '$VERSION' not found in available versions. Removing config."
    rm -f "$CONFIG_FILE"
    exit 1
  fi
  echo "Using saved Wine version: $VERSION"
else
  echo "Available Wine versions:"
  i=1
  mapfile -t versions_array < <(printf "%s\n" "${!WINE_VERSIONS[@]}" | sort)
  for v in "${versions_array[@]}"; do
    echo "  $i) $v"
    ((i++))
  done
  echo "Press Enter to select default version: $DEFAULT_VERSION"

  while true; do
    read -rp "Enter choice number (or press Enter for default): " choice
    if [[ -z "$choice" ]]; then
      VERSION=$DEFAULT_VERSION
      echo "No choice entered, defaulting to $VERSION."
      echo "$VERSION" > "$CONFIG_FILE"
      break
    elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice < i )); then
      VERSION=${versions_array[$((choice - 1))]}
      echo "You selected: $VERSION"
      echo "$VERSION" > "$CONFIG_FILE"
      break
    else
      echo "Invalid input. Please enter a number between 1 and $((i - 1)) or press Enter for default."
    fi
  done
fi

ARCHIVE_URL="${WINE_VERSIONS[$VERSION]}"
ARCHIVE_PATH="$BASE_DIR/$VERSION.tar.gz"

if [ -d "$EXTRACT_DIR" ]; then
  echo "✔ Mactan runner already extracted, using existing files."
else
  if [ ! -f "$ARCHIVE_PATH" ]; then
    echo "⭳ Downloading Mactan runner $VERSION..."
    wget -O "$ARCHIVE_PATH" "$ARCHIVE_URL" || { echo "Download failed! Exiting."; exit 1; }
  else
    echo "✔ Archive for $VERSION already downloaded."
  fi

  echo "🗜 Extracting Mactan runner $VERSION to $EXTRACT_DIR (stripping top-level directory)..."
  mkdir -p "$EXTRACT_DIR"
  tar xfz "$ARCHIVE_PATH" --strip-components=1 -C "$EXTRACT_DIR" || { echo "Extraction failed! Exiting."; exit 1; }
fi

echo "Setup complete for Mactan Wine Runner version $VERSION."
echo "To switch from $VERSION to another wine-runner: rm -rf rm $PWD/runners/.mactan_wine_version"

# Setup fake DLLs for DLSS // only if not already existing

echo "============ Setting up fake DLLs for DLSS ============"

FAKE_DLLS_DIR="$HOME/Games/star-citizen/drive_c/windows/system32/"
cd "$FAKE_DLLS_DIR" || { echo "✘ Failed to change directory to $FAKE_DLLS_DIR"; exit 1; }

for dll in cryptbase.dll devobject.dll drvstore.dll; do
  if [ -f "$dll" ]; then
    echo "✔ $dll already exists, skipping."
  else
    ln -s security.dll "$dll"
    echo "⭳ Created fake $dll"
  fi
done
                                                                                                                    
for file in /usr/lib/nvidia/wine/*.dll; do
 if [ -f "$file" ]; then
    echo "✔ $file in system32 already exists, skipping."
    else
    dest="$HOME/Games/star-citizen/drive_c/windows/system32/$(basename "$file")"
    [ "$file" != "$dest" ] && ln -s "$file" "$dest"
    fi
done


# Export Wine-related environment variables

echo "========== Configuring Wine Environment =========="
launch_log="$WINEPREFIX/sc-launch.log"
export WINEDLLOVERRIDES="dxgi,d3d8,d3d9,d3d10core,d3d11,nvapi,nvapi64,nvofapi64=n,b;winemenubuilder="
export WINE_LARGE_ADDRESS_AWARE="1"
export WINEDEBUG=-all
# Force NTSYNC, E/FSYNC fallback
export WINEESYNC
export WINEFSYNC

# Disabled prompting // sudo is already gained in startgame script

echo "========== Loading ntsync kernel module =========="
if lsmod | grep -q ntsync; then
  echo "✔ ntsync already loaded."
else
  if sudo -n modprobe ntsync 2>/dev/null; then
    echo "✔ ntsync loaded without password prompt."
  else
    echo "✘ Failed to load ntsync without prompt."
    echo "Please run 'sudo modprobe ntsync' manually and re-run this script."
    echo "Requires Kernel 6.14 or newer"
    echo "Falling back to E/Fsync"
  fi
fi

CONFIG_FILE="$HOME/Games/star-citizen/.graphics_api_choice"

# Check if the user has already made a choice
# We need that cause Vulkan is crashing on NVIDIA without disabling NV-Cache
# Building DXVK 2.7 from source + 570 Branch is recommended for Vulkan
if [[ -f "$CONFIG_FILE" ]]; then
    choice=$(<"$CONFIG_FILE")
    echo "Using saved graphics API choice: $choice"
    echo "To change this, delete or edit: $CONFIG_FILE"
else
    echo "Which graphics API do you want to use?"
    echo "1) Vulkan"
    echo "2) Direct3D 11"
    echo "3) I don't know (default behavior)"
    read -rp "Enter 1, 2 or 3: " answer

    case "$answer" in
        1) choice="vulkan" ;;
        2) choice="d3d11" ;;
        *) choice="unknown" ;;
    esac

    echo "$choice" > "$CONFIG_FILE"
    echo "Saved your choice: $choice"
fi

# Apply settings based on choice
case "$choice" in
    vulkan)
        export __GL_SHADER_DISK_CACHE=0
        ;;
    d3d11|unknown)
        export __GL_SHADER_DISK_CACHE=1
        ;;
esac

# Proton / umu; no alien startscripts; not in use rn
export GAMEID=umu-starcitizen-noPreset-noProton
export STORE=none
# Enable EAC
export EOS_USE_ANTICHEATCLIENTNULL=0
# Libcuda.so
# Debug: https://github.com/Vingian/libcudatest/blob/main/libcudatest.c
#export LD_LIBRARY_PATH=$PWD/usr/lib/libcuda.so
# DLSS Version 4
export PROTON_ENABLE_NGX_UPDATER=1
export DXVK_NVAPI_DRS_SETTINGS="NGX_DLSS_RR_OVERRIDE=on,NGX_DLSS_SR_OVERRIDE=on,NGX_DLSS_FG_OVERRIDE=on,NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest,NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest"
# Enable DLSS debug overlay in-game; to disable, set DLSSIndicator=1,DLSSGIndicator=1
export DXVK_NVAPI_SET_NGX_DEBUG_OPTIONS="DLSSIndicator=1024,DLSSGIndicator=2"
# NVIDIA related
#WINE_BIN="/home/hans/Games/star-citizen/runners/wine_runner/bin/wine"
#"$WINE_BIN" reg add "HKLM\\Software\\NVIDIA Corporation\\Global\\NGXCore" /v "FullPath" /t REG_SZ /d "C:\\Windows\\System32" /f
WINE_BIN="/home/hans/Games/star-citizen/runners/wine_runner/bin/wine"
REG_PATH="HKLM\\Software\\NVIDIA Corporation\\Global\\NGXCore"
VALUE_NAME="FullPath"
EXPECTED_VALUE="C:\\Windows\\System32"

# Check if the value already exists and matches what we want
CURRENT_VALUE=$("$WINE_BIN" reg query "$REG_PATH" /v "$VALUE_NAME" 2>/dev/null | grep "$VALUE_NAME" | awk '{print $NF}')

# Add the value only if it's missing or different
if [ "$CURRENT_VALUE" != "$EXPECTED_VALUE" ]; then
    echo "Adding or updating registry key..."
    "$WINE_BIN" reg add "$REG_PATH" /v "$VALUE_NAME" /t REG_SZ /d "$EXPECTED_VALUE" /f
else
    echo "Registry key already set. Skipping."
fi

export __GL_SHADER_DISK_CACHE_SIZE=10737418240
export __GL_SHADER_DISK_CACHE_PATH="$WINEPREFIX"
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
export MESA_SHADER_CACHE_DIR="$WINEPREFIX"
export MESA_SHADER_CACHE_MAX_SIZE="10G"
# Even when HDR is not used its fine to leave it enabled since ingame it is disabled by default
export DXVK_HDR="1"
export DXVK_LOG_LEVEL="error"
export DXVK_NVAPIHACK="0"
export DXVK_ENABLE_NVAPI="1"
export PROTON_DXVK_D3D8="1"
# Enables winewayland driver; required for VULKAN
export DISPLAY=

# Optional HUDs
# export DXVK_HUD=fps
# export MANGOHUD=1

export wine_path="$WINEPREFIX/runners/wine_runner/bin/"
export WINE_PATH="$wine_path"


echo "==================== Paths used ======================"
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

trap "update_check; \"$wine_path\"/wineserver -k" EXIT
update_check() {
  "$wine_path"/wineserver -k
}

trap update_check EXIT



echo "=============== Launching Star Citizen ==============="
# You can pin Cores to SC using taskset
# e.g. /usr/bin/taskset -c 0-7,16-23 "$wine_path"/wine "C:\\Program Files\\Roberts Space Industries\\RSI Launcher\\RSI Launcher.exe" --disable-gpu --in-process-gpu > "$launch_log" 2>&1
# Check your CPU specs
# Not recommended as default
"$wine_path"/wine "C:\\Program Files\\Roberts Space Industries\\RSI Launcher\\RSI Launcher.exe" --disable-gpu --in-process-gpu > "$launch_log" 2>&1
