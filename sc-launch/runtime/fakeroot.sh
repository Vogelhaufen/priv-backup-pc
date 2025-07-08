#!/bin/bash

set -e

# Game Runner Script with Bubblewrap Sandbox

# Step 1: Argument Check
if [ $# -lt 1 ]; then
  echo ""
  echo "Usage: $0 <game_script_or_binary> [args...]"
  echo ""
  exit 1
fi

# Step 2: Variable Setup
PATCHED_LIB="$HOME/Games/star-citizen/libcuda.patched.so"
GAME_EXEC="$(realpath "$1")"
shift
GAMEDIR="$(dirname "$GAME_EXEC")"
WINEPREFIX="$HOME/Games/star-citizen"

# Dynamic Wayland socket detection
if [ -n "$WAYLAND_DISPLAY" ] && [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/$WAYLAND_DISPLAY" ]; then
  WAYLAND_SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/$WAYLAND_DISPLAY"
else
  # Auto-detect first available wayland socket
  for sock in "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/wayland-*; do
    if [ -S "$sock" ]; then
      WAYLAND_SOCKET="$sock"
      WAYLAND_DISPLAY="$(basename "$sock")"
      break
    fi
  done
fi

echo "Preparing sandbox environment for:"
echo "  Game executable: $GAME_EXEC"
echo "  Patched libcuda: $PATCHED_LIB"
echo "  Wine prefix:     $WINEPREFIX"
echo "  Wayland socket:  $WAYLAND_SOCKET"
echo ""

# Step 3: Sanity Checks
if [ ! -f "$PATCHED_LIB" ]; then
  echo "Error: Patched CUDA library not found at:"
  echo "  $PATCHED_LIB"
  exit 2
fi

if [ ! -S "$WAYLAND_SOCKET" ]; then
  echo "Warning: Wayland socket not found. Falling back to X11 if available..."
fi

# Step 4: Bubblewrap Arguments
BWRAP_ARGS=(
  --ro-bind / /
  --dev /dev
  --proc /proc
  --tmpfs /tmp
  --ro-bind /sys /sys

  --bind "$PATCHED_LIB" /usr/lib/libcuda.so
  # NO --bind "$PATCHED_LIB" /usr/lib/libcuda.so.575.64.03

  --bind "$GAMEDIR" "$GAMEDIR"
  --bind "$HOME" "$HOME"

  --dev-bind /dev/nvidia0 /dev/nvidia0
  --dev-bind /dev/nvidiactl /dev/nvidiactl
  --dev-bind /dev/nvidia-uvm /dev/nvidia-uvm
  --dev-bind /dev/nvidia-uvm-tools /dev/nvidia-uvm-tools
  --dev-bind /dev/nvidia-modeset /dev/nvidia-modeset
  --dev-bind /dev/dri /dev/dri
  --dev-bind /dev/shm /dev/shm

  # NO --dev-bind /dev/input to avoid warppointer conflict, wayland socket handles it fine
  --bind /tmp/.X11-unix /tmp/.X11-unix
  --bind "$WAYLAND_SOCKET" "$WAYLAND_SOCKET"
  --bind "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/pipewire-0" "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/pipewire-0"

  --setenv LD_LIBRARY_PATH /usr/lib
  --setenv HOME "$HOME"
  --setenv PATH "$PATH"
  --setenv WAYLAND_DISPLAY "$WAYLAND_DISPLAY"
  --setenv DISPLAY "$DISPLAY"
  --setenv WINEPREFIX "$WINEPREFIX"
)

# Step 5: Run the Game
echo "Launching the game inside a sandboxed environment..."
echo "-----------------------------------------------------"
bwrap "${BWRAP_ARGS[@]}" "$GAME_EXEC" "$@"

# Step 6: Exit Message
echo ""
echo "Game exited."
echo "Fakeroot sandbox environment was successfully used and cleaned up."
echo ""
