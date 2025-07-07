#!/bin/bash
# Vulkan + NVIDIA + Wine ultra performance environment for Wayland
# Runs exactly one command with optimized env vars without affecting current shell

if [ $# -eq 0 ]; then
  echo "Usage: $0 <command> [args...]"
  exit 1
fi

# -------- NVIDIA & Vulkan environment --------
export NV_API_DISABLE_AUTO_BOOST=1
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_PATH="$HOME/.cache/nvidia-shaders"
export __GL_THREADED_OPTIMIZATIONS=1
export __GL_MaxFramesAllowed=1
export __GL_SYNC_TO_VBLANK=0
export __GL_LOG_MAX_FRAMES=1

export VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/nvidia_icd.json"
export VK_LAYER_PATH="/usr/share/vulkan/explicit_layer.d"
export VK_INSTANCE_LAYERS="VK_LAYER_NV_optimus"
export VK_LOADER_DEBUG=0

export NV_DXVK_ENABLE=1
export DXVK_ENABLE_NVAPI=1
export DXVK_ENABLE_D3D11=1
export DXVK_ENABLE_D3D10=1

# -------- Wine environment --------
#covered in another config

# -------- CPU & Misc --------
export __GL_CPU_AFFINITY=0xFF
export __GL_THREAD_MODEL=1
export __GL_SKIP_SHELL_INIT=1

# -------- Wayland related --------
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export WLR_NO_HARDWARE_CURSORS=1

# -------- Misc NVIDIA driver tweaks --------
export __GL_DISALLOW_PBO=0
export __GL_ENABLE_FIXED_ATTRIBS=1

# -------- Memory and caching --------
export VK_EXT_GLOBAL_PRIORITY="VK_QUEUE_GLOBAL_PRIORITY_HIGH_EXT"

# -------- Additional experimental/advanced --------
export __GL_ALLOW_UNOFFICIAL_PROTOCOL=1

# -------- Execute the command passed as arguments --------
exec "$@"
