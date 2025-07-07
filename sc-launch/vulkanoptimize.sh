#!/bin/bash

# ---------------------------
# DLSS Vulkan launcher script
# Optimized & robust environment setup for NVIDIA + Vulkan + shader cache
# !UNSTABLE/TESTING!
# ---------------------------

set -euo pipefail
IFS=$'\n\t'

# --- Check NVIDIA driver & Vulkan ICD presence ---

if ! command -v vulkaninfo &>/dev/null; then
  echo "Error: 'vulkaninfo' command not found. Please install Vulkan tools." >&2
  exit 1
fi

if ! vulkaninfo &>/dev/null; then
  echo "Error: Vulkan does not seem to be working on your system." >&2
  exit 1
fi

if [[ ! -f /usr/share/vulkan/icd.d/nvidia_icd.json ]]; then
  echo "Error: NVIDIA Vulkan ICD file not found at /usr/share/vulkan/icd.d/nvidia_icd.json" >&2
  exit 1
fi

# --- NVIDIA environment variables ---

# Disable NVIDIA GPU auto-boost for consistent clock speeds
export NV_API_DISABLE_AUTO_BOOST=1

# Vulkan ICD and explicit layer paths
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
export VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d

# Enable NVIDIA Optimus Vulkan layer to force Vulkan on NVIDIA GPU if hybrid graphics
export VK_INSTANCE_LAYERS=VK_LAYER_NV_optimus

# Enable persistent NVIDIA shader disk cache for better load times and less stutter
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1

# Use a dedicated cache path (create if missing)
CACHE_DIR="$HOME/.cache/nvidia-shaders"
mkdir -p "$CACHE_DIR"
export __GL_SHADER_DISK_CACHE_PATH="$CACHE_DIR"

# Lower input latency, boost responsiveness
export __GL_MaxFramesAllowed=1

# Enable threaded optimizations in NVIDIA driver for better CPU/GPU concurrency
export __GL_THREADED_OPTIMIZATIONS=1

# Optional: enable DLSS-specific env variables if applicable (depends on app support)
# export NV_DLSS_ENABLE=1
# export NV_DLSS_SHARPENING=0.5

# Print debug info (optional, comment out if not needed)
echo "Launching with environment:"
echo "  NV_API_DISABLE_AUTO_BOOST=$NV_API_DISABLE_AUTO_BOOST"
echo "  VK_ICD_FILENAMES=$VK_ICD_FILENAMES"
echo "  VK_LAYER_PATH=$VK_LAYER_PATH"
echo "  VK_INSTANCE_LAYERS=$VK_INSTANCE_LAYERS"
echo "  __GL_SHADER_DISK_CACHE=$__GL_SHADER_DISK_CACHE"
echo "  __GL_SHADER_DISK_CACHE_PATH=$__GL_SHADER_DISK_CACHE_PATH"
echo "  __GL_MaxFramesAllowed=$__GL_MaxFramesAllowed"
echo "  __GL_THREADED_OPTIMIZATIONS=$__GL_THREADED_OPTIMIZATIONS"
echo ""

# --- Launch the actual app with passed arguments ---
exec "$@"
