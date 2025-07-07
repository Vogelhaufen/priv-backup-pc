#!/usr/bin/env bash

# ╔════════════════════════════════════════════════════════════╗
# ║      VULKAN + NVIDIA ULTRA-ΩMEGA PERFORMANCE LAUNCHER     ║
# ║        Built for gaming, low-latency, shader sync,         ║
# ║    and max driver-side concurrency & cache efficiency      ║
# ╚════════════════════════════════════════════════════════════╝

set -euo pipefail
IFS=$'\n\t'

# -- Ensure a command was passed --
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <executable> [args...]" >&2
  exit 1
fi

# === HARDCORE ENVIRONMENT SETUP ===

# Vulkan routing to NVIDIA
export VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/nvidia_icd.json"
export VK_LAYER_PATH="/usr/share/vulkan/explicit_layer.d"
export VK_INSTANCE_LAYERS="VK_LAYER_NV_optimus"

# Shader cache to max performance location
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
export __GL_SHADER_DISK_CACHE_PATH="${HOME}/.cache/nvidia-ultra-shaders"
export __GL_GSYNC_ALLOWED=0
export __GL_FORCE_SWAP_INTERVAL=0
export __GL_GLSL_OPTIMIZE=1
export __GL_ALLOW_UNOFFICIAL_PROTOCOL=1
mkdir -p "$__GL_SHADER_DISK_CACHE_PATH"

# Minimize latency, maximize driver throughput
export __GL_MaxFramesAllowed=1                   # Only render what's visible
export __GL_THREADED_OPTIMIZATIONS=1             # Multithread driver logic
export __GL_YIELD="USLEEP"                       # Better CPU-GPU sync timing
export __GL_SYNC_TO_VBLANK=0                     # Disable internal vsync (optional)

# Disable dynamic GPU boost (force consistent clocks)
export NV_API_DISABLE_AUTO_BOOST=1

# Optional: Vulkan memory allocation tweak for better pooling (dev only)
# export VK_DEFER_DESTROY_RESOURCES=1

# Optional: DLSS/Reflex support (for compatible apps)
# export PROTON_ENABLE_NVAPI=1
# export PROTON_HIDE_NVIDIA_GPU=0
# export ENABLE_DLSS=1

# Optional: Disable power management throttling
if command -v nvidia-smi &>/dev/null; then
  nvidia-smi -pm 1 &>/dev/null || true
fi

# Optional: Lock max performance clocks (DANGEROUS if not cooled properly)
# nvidia-smi -lgc 2100,2100  # Uncomment + change if you know your GPU's limit

# Disable desktop compositor (Wayland or X11)
#if command -v gnome-extensions &>/dev/null; then
#  gnome-extensions disable background-logo@gnome-shell-extensions.gcampax.github.com || true
#fi

# === DEBUG OPTIONS ===
# Uncomment to get verbose Vulkan debug info (useful for testing)
# export VK_LOADER_DEBUG=all
# export MESA_VK_WSI_DEBUG=all
# export VK_INSTANCE_LAYERS="VK_LAYER_KHRONOS_validation:$VK_INSTANCE_LAYERS"

# === DIAGNOSTICS ===
echo -e "\033[1;32m[Ω] Launching with Vulkan + NVIDIA Ultra Performance...\033[0m"
env | grep -E '__GL_|VK_|NV_API' | sort
echo ""
echo ">>> EXECUTING: $*"
echo ""

# === EXEC ===
exec "$@"
