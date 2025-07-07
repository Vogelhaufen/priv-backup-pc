#!/bin/bash
# BATMAN’S OMEGA ULTRA MEGA TURBO HYPER VULKAN NINJA NVIDIA POWER LAUNCHER 9000
# Ultra-optimized Vulkan + NVIDIA + Wine environment launcher for Wayland gaming

# Colors for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Banner function
print_banner() {
  echo -e "${CYAN}"
  echo "==========================================================="
  echo "  🦇 BATMAN’S OMEGA ULTRA MEGA TURBO HYPER VULKAN NINJA NVIDIA POWER LAUNCHER 9000 🦇"
  echo "==========================================================="
  echo -e "${RESET}"
}

# Variables and descriptions
declare -A env_vars=(
  [NV_API_DISABLE_AUTO_BOOST]="1  # Disable NVIDIA GPU auto boost (can stabilize clocks)"
  [__GL_SHADER_DISK_CACHE]="1  # Enable NVIDIA shader disk cache"
  [__GL_SHADER_DISK_CACHE_PATH]="$HOME/.cache/nvidia-shaders  # Shader cache location"
  [__GL_THREADED_OPTIMIZATIONS]="1  # Enable multithreaded OpenGL optimizations"
  [__GL_MaxFramesAllowed]="1  # Limit max frames queued"
  [__GL_SYNC_TO_VBLANK]="0  # Disable V-Sync at driver level"
  [__GL_LOG_MAX_FRAMES]="1  # Log max frames (debugging)"
  [VK_ICD_FILENAMES]="/usr/share/vulkan/icd.d/nvidia_icd.json  # Vulkan ICD loader for NVIDIA"
  [VK_LAYER_PATH]="/usr/share/vulkan/explicit_layer.d  # Vulkan explicit layers path"
  [VK_INSTANCE_LAYERS]="VK_LAYER_NV_optimus  # Enable Optimus Vulkan layer"
  [VK_LOADER_DEBUG]="0  # Vulkan loader debug level (0=off)"
  [NV_DXVK_ENABLE]="1  # Enable NVAPI in DXVK"
  [DXVK_ENABLE_NVAPI]="1  # Enable NVAPI in DXVK"
  [DXVK_ENABLE_D3D11]="1  # Enable D3D11 support in DXVK"
  [DXVK_ENABLE_D3D10]="1  # Enable D3D10 support in DXVK"
  [WINEFSYNC]="0  # Disable FSYNC (not patched)"
  [WINEESYNC]="0  # Disable ESYNC (using NTsync)"
  [WINEDLLOVERRIDES]="ntdll.dll=n  # Override ntdll in Wine"
  [WINEDEBUG]="-all  # Disable Wine debug output"
  [DXVK_LOG_LEVEL]="none  # DXVK log level"
  [__GL_CPU_AFFINITY]="0xFF  # CPU affinity mask for NVIDIA driver"
  [__GL_THREAD_MODEL]="1  # NVIDIA OpenGL thread model"
  [__GL_SKIP_SHELL_INIT]="1  # Skip some shell init for performance"
  [QT_QPA_PLATFORM]="wayland  # QT apps use Wayland"
  [SDL_VIDEODRIVER]="wayland  # SDL apps use Wayland"
  [WLR_NO_HARDWARE_CURSORS]="1  # Disable hardware cursors in wlroots compositors"
  [__GL_DISALLOW_PBO]="0  # Allow Pixel Buffer Objects"
  [__GL_ENABLE_FIXED_ATTRIBS]="1  # Enable fixed attribs in NVIDIA driver"
  [VK_EXT_GLOBAL_PRIORITY]="VK_QUEUE_GLOBAL_PRIORITY_HIGH_EXT  # Vulkan queue priority"
  [__GL_ALLOW_UNOFFICIAL_PROTOCOL]="1  # Allow unofficial NVIDIA protocol (experimental)"
)

print_banner

echo -e "${YELLOW}Setting environment variables for OMEGA ULTRA performance...${RESET}"
echo

for var in "${!env_vars[@]}"; do
  val="${!var:-undefined}"
  echo -e "${GREEN}$var${RESET} = ${CYAN}${val}${RESET}  # ${env_vars[$var]#*#}"
done

echo
echo -e "${YELLOW}Launching:${RESET} $*"
echo

# Export env vars before exec
for var in "${!env_vars[@]}"; do
  value="${env_vars[$var]}"
  value="${value%%#*}"
  value="${value%" "}"
  export $var="$value"
done

exec "$@"
