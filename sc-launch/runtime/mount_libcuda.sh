#!/usr/bin/env bash
set -euo pipefail

PATCHED_CUDA="$HOME/Games/star-citizen/libcuda.patched.so"
UNMOUNT_ONLY=0

usage() {
  cat <<EOF
Usage: $0 [--patched-lib <path>] [--unmount]

Options:
  --patched-lib <path>   Specify path to patched libcuda.so
  --unmount              Only unmount patched libcuda bind mount and exit
  -h, --help             Show this help message
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --patched-lib)
      shift
      if [[ $# -eq 0 ]]; then
        echo "✘ Missing argument for --patched-lib"
        exit 1
      fi
      PATCHED_CUDA="$1"
      ;;
    --unmount)
      UNMOUNT_ONLY=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "✘ Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

echo "============== Locating 64-bit libcuda.so ============="

LIBCUDA_ORIG=$(realpath $(ldconfig -p | \
    awk '/libcuda.so.1$/{if($0 ~ /libc6,x86-64/) print $NF;}' | head -n1))

if [ -z "$LIBCUDA_ORIG" ]; then
    echo "✘ No 64-bit libcuda.so found!"
    exit 1
fi
echo "✔ Found 64-bit libcuda.so at: $LIBCUDA_ORIG"

if [[ "$UNMOUNT_ONLY" -eq 1 ]]; then
  echo "Unmounting patched libcuda from $LIBCUDA_ORIG"
  if mountpoint -q "$LIBCUDA_ORIG"; then
    sudo umount "$LIBCUDA_ORIG"
    echo "✔ Unmounted successfully."
  else
    echo "No mount found at $LIBCUDA_ORIG."
  fi
  exit 0
fi

if [ ! -f "$PATCHED_CUDA" ]; then
    echo "✘ Patched libcuda not found at $PATCHED_CUDA"
    exit 1
fi
echo "======= Mounting $PATCHED_CUDA to $LIBCUDA_ORIG ======="

if mountpoint -q "$LIBCUDA_ORIG"; then
    echo "Unmounting existing mount at $LIBCUDA_ORIG"
    sudo umount "$LIBCUDA_ORIG"
fi

sudo mount --bind "$PATCHED_CUDA" "$LIBCUDA_ORIG"

mount | grep -i cuda || true
