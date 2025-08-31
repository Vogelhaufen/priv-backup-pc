#!/usr/bin/env bash
#--------------------------------------#
# CONFIGURATION & ENVIRONMENT SETUP    #
#--------------------------------------#

# BEGIN env var

# Enables winewayland driver; required for VULKAN
# must be set before REG settings otherwise the script will die
export DISPLAY=

# disable E/FSYNC
export WINEFSYNC=0
export WINEESYNC=0

# Game and Store identifiers
export GAMEID="umu-starcitizen-noPreset-noProton"
export STORE="none"

# Enable Easy Anti-Cheat client
export EOS_USE_ANTICHEATCLIENTNULL="0"

# NVIDIA DLSS settings
export PROTON_ENABLE_NGX_UPDATER="1"
export DXVK_NVAPI_DRS_SETTINGS="NGX_DLSS_RR_OVERRIDE=on,NGX_DLSS_SR_OVERRIDE=on,NGX_DLSS_FG_OVERRIDE=on,NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest,NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION=render_preset_latest"
export DXVK_NVAPI_SET_NGX_DEBUG_OPTIONS="DLSSIndicator=1024,DLSSGIndicator=2"

# Vulkan and DXVK settings
export DXVK_HDR="0"
export DXVK_LOG_LEVEL="error"
export DXVK_NVAPIHACK="0"
export DXVK_ENABLE_NVAPI="1"
export DXVK_FILTER_DEVICE_NAME="$(vulkaninfo --summary | grep -i deviceName | grep -i NVIDIA | head -n1 | awk -F'= *' '{print $2}')"

# NVIDIA OpenGL shader cache settings
export __GL_SHADER_DISK_CACHE_SIZE="10737418240"
export __GL_SHADER_DISK_CACHE_PATH="$WINEPREFIX"
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP="1"

# Mesa shader cache settings
export MESA_SHADER_CACHE_DIR="$WINEPREFIX"
export MESA_SHADER_CACHE_MAX_SIZE="10G"

# LAUNCH_LOG; 1=run without redirecting output (interactive CLI logging); 0=log to file
# 0 is recommended to skate around bugs when logging to CLI
export LAUNCH_LOG="sc-launch.log"
export CLI_LOG="0"

# LSFG settings
# https://github.com/PancakeTAS/lsfg-vk
# 240Hz monitor settings // 60*4 = 240 // change Framerate to adapt

# "1" to enable lsfg-vk, "0" to disable lsfg-vk
export ENABLE_LSFG_ALL="1"   

if [ "$ENABLE_LSFG_ALL" = "1" ]; then
  export LSFG_LEGACY="1"
  export ENABLE_LSFG="1"
  export LSFG_MULTIPLIER="4"
  export LSFG_PERFORMANCE_MODE="1"
  export LSFG_FLOW_SCALE="0.75"
  export LSFG_HDR_MODE="0"
  export VK_LOADER_DEBUG="all"
  export DXVK_FRAME_RATE="60"
  export VKD3D_FRAME_RATE="60"
else
  unset LSFG_LEGACY
  unset ENABLE_LSFG
  unset LSFG_MULTIPLIER
  unset LSFG_PERFORMANCE_MODE
  unset LSFG_PERF_MODE
  unset LSFG_FLOW_SCALE
  unset LSFG_HDR_MODE
  unset VK_LOADER_DEBUG
  unset DXVK_FRAME_RATE
  unset VKD3D_FRAME_RATE
fi

# Optional HUDs
# export DXVK_HUD="fps"
# export MANGOHUD="1"

# already done in the script; documentation
# Vulkan option - install vkd3d with winetricks 
# $WINEPREFIX winetricks --self-update
# $WINEPREFIX winetricks vkd3d
# $WINEPREFIX winetricks dxvk
# $WINEPREFIX winetricks dxkk_nvapi

# END of env var


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
SC_LAUNCH_SCRIPT="sc-launch.sh"
ENVEXPORT_FILE="$PWD/ENVEXPORT"

# Clear ENVEXPORT_FILE if exists
> "$ENVEXPORT_FILE"

if [ -f "$SC_LAUNCH_SCRIPT" ]; then
  grep "export WINEPREFIX" "$SC_LAUNCH_SCRIPT" > "$ENVEXPORT_FILE"
fi

if [ -f "$ENVEXPORT_FILE" ] && grep -q "WINEPREFIX" "$ENVEXPORT_FILE"; then
  . "$ENVEXPORT_FILE"
  echo "✔ WINEPREFIX loaded: $WINEPREFIX"
else
  echo "✘ [ERROR] WINEPREFIX not found in $SC_LAUNCH_SCRIPT or script missing"
  echo "Using default WINEPREFIX=$HOME/Games/star-citizen"
  export WINEPREFIX="$HOME/Games/star-citizen"
fi

# i hate this part; ToDO
export wine_path="$WINEPREFIX/runners/wine_runner/bin"
export WINE_PATH="$wine_path"

echo "========== Checking DXVK and DXVK/NVAPI DLLs =========="
# hardcoded VERSION for downgrades; rm .dxvk_versions; replace VERSION to change during runtime
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


# Setup fake DLLs for DLSS // only if not already existing // deprecated since lug-wine-10.12

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
    dest="$HOME/Games/star-citizen/drive_c/windows/system32/$(basename "$file")"

    if [ -f "$dest" ]; then
        echo "✔ $dest already exists, skipping."
    else
        echo "→ Linking $file → $dest"
        ln -s "$file" "$dest"
    fi
done

echo "============= LUG Wine Runner Setup ==============="

extract_silent() {
  local archive_file="$1"
  local target_dir="$2"
  [ -z "$archive_file" ] && return 1

  mkdir -p "$target_dir" || return 1
  local tmp_dir
  tmp_dir=$(mktemp -d) || return 1

  case "$archive_file" in
    *.tar.gz|*.tgz)
      tar -xzf "$archive_file" -C "$tmp_dir" >/dev/null 2>&1 || return 1
      ;;
    *.tar.zst)
      tar --use-compress-program=unzstd -xf "$archive_file" -C "$tmp_dir" >/dev/null 2>&1 || return 1
      ;;
    *)
      return 1
      ;;
  esac

  case "$archive_file" in
    *.tar.gz|*.tgz)
      # Simulate --strip-components=1
      shopt -s dotglob nullglob
      first_dir=("$tmp_dir"/*)
      if [ -d "${first_dir[0]}" ]; then
        mv "${first_dir[0]}"/* "$target_dir" 2>/dev/null
      else
        mv "$tmp_dir"/* "$target_dir"
      fi
      ;;
    *)
      mv "$tmp_dir"/* "$target_dir"
      ;;
  esac

  rm -rf "$tmp_dir"
}

declare -A WINE_VERSIONS=(
  
  ["10.12-1-DLSS-NTSYNC"]="https://github.com/starcitizen-lug/lug-wine/releases/download/10.12-1/lug-wine-tkg-staging-ntsync-git-10.12-1.tar.gz"
  ["10.12-DLSS-NTSYNC"]="https://github.com/starcitizen-lug/lug-wine/releases/download/10.12/lug-wine-tkg-staging-ntsync-git-10.12.tar.gz"
)

BASE_DIR="$WINEPREFIX/runners"
EXTRACT_DIR="$BASE_DIR/wine_runner"
CONFIG_FILE="$BASE_DIR/.LUG_wine_version"
DEFAULT_VERSION="10.12-DLSS-NTSYNC"

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
ARCHIVE_NAME=$(basename "$ARCHIVE_URL")
ARCHIVE_PATH="$BASE_DIR/$ARCHIVE_NAME"

if [ -d "$EXTRACT_DIR" ]; then
  echo "✔ LUG runner already extracted, using existing files."
else
  if [ ! -f "$ARCHIVE_PATH" ]; then
    echo "⭳ Downloading LUG runner $VERSION..."
    wget -O "$ARCHIVE_PATH" "$ARCHIVE_URL" || { echo "Download failed! Exiting."; exit 1; }
  else
    echo "✔ Archive for $VERSION already downloaded."
  fi

  echo "🗜 Extracting LUG runner $VERSION to $EXTRACT_DIR (conditional strip)..."
  extract_silent "$ARCHIVE_PATH" "$EXTRACT_DIR" || { echo "Extraction failed! Exiting."; exit 1; }
fi

echo "Setup complete for LUG Wine Runner version $VERSION."
echo "To switch from $VERSION to another wine-runner: rm -rf $WINEPREFIX/runners"

# exporting WINE*SYNC is a failsafe, usually NTSYNC > E/FSYNC
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
    export WINEFSYNC=1
    export WINEESYNC=1
  fi
fi

# REG Key to enable NGX // deprecated since lug-wine-10.12
echo "============= Setting Registry Keys =============="
WINE_BIN="$WINEPREFIX/runners/wine_runner/bin/wine"
REG_PATH="HKLM\\Software\\NVIDIA Corporation\\Global\\NGXCore"
VALUE_NAME="FullPath"
EXPECTED_VALUE_SET="C:\\Windows\\System32"
EXPECTED_VALUE_CHECK="C:\Windows\System32"

REG_QUERY_OUTPUT=$("$WINE_BIN" reg query "$REG_PATH" /v "$VALUE_NAME" 2>/dev/null)

CURRENT_VALUE=$(echo "$REG_QUERY_OUTPUT" \
  | grep "$VALUE_NAME" \
  | tr -s ' ' \
  | cut -d ' ' -f4- \
  | sed -e "s/^[[:space:]\'\"]*//" -e "s/[[:space:]\'\"]*$//")

echo "Current registry value: '$CURRENT_VALUE'"

if [ "$CURRENT_VALUE" = "$EXPECTED_VALUE_CHECK" ]; then
    echo "Registry key already set. Skipping."
else
    echo "Setting registry key..."
    "$WINE_BIN" reg add "$REG_PATH" /v "$VALUE_NAME" /t REG_SZ /d "$EXPECTED_VALUE_SET" /f
fi
# END REG Key to enable NGX

echo "==================== Paths used ======================"
echo "WINEPREFIX dir: $WINEPREFIX"
echo "Wine runner bin dir: $wine_path"

# extracted from lug-helper script
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

# You can pin Cores to SC using taskset
# e.g. /usr/bin/taskset -c 0-7,16-23 "$wine_path"/wine "C:\\Program Files\\Roberts Space Industries\\RSI Launcher\\RSI Launcher.exe" --disable-gpu --in-process-gpu > "$launch_log" 2>&1
# Check your CPU specs
# Not recommended as default
echo "=============== Launching Star Citizen ==============="

if [ "$CLI_LOG" = "1" ]; then
  # Run without redirecting output (interactive CLI logging)
  "$wine_path"/wine "C:\\Program Files\\Roberts Space Industries\\RSI Launcher\\RSI Launcher.exe" --disable-gpu --in-process-gpu
else
  # Run with output redirected to log file
  "$wine_path"/wine "C:\\Program Files\\Roberts Space Industries\\RSI Launcher\\RSI Launcher.exe" --disable-gpu --in-process-gpu > "$LAUNCH_LOG" 2>&1
fi
