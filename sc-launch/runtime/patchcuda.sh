#!/usr/bin/env bash
# Find the real 64-bit libcuda.so
echo "========== Locating 64-bit libcuda.so =========="

LIBCUDA_ORIG=$(realpath $(ldconfig -p | awk '/libcuda.so.1$/{if($0 ~ /libc6,x86-64/) print $NF;}' | head -n1))

if [ -z "$LIBCUDA_ORIG" ]; then
  echo "✘ No 64-bit libcuda.so found!"
  exit 1
else
  echo "✔ Found 64-bit libcuda.so at: $LIBCUDA_ORIG"
fi

# Patch libcuda.so for DLSSv4 support
PATCHED_LIB="$PWD/libcuda.patched.so"
HASHFILE="$PWD/libcuda.so.md5"   # non-hidden, saved in script start directory

# ensure md5sum exists
if ! command -v md5sum >/dev/null 2>&1; then
  echo "✘ md5sum not found. Install coreutils (md5sum)."
  exit 1
fi

CURRENT_HASH=$(md5sum "$LIBCUDA_ORIG" | cut -d ' ' -f 1)

if [ ! -f "$HASHFILE" ] || [ "$CURRENT_HASH" != "$(cat "$HASHFILE")" ] || [ ! -f "$PATCHED_LIB" ]; then
  echo "⚠ libcuda.so changed or patch missing. Applying patch..."
  echo -ne $(od -An -tx1 -v "$LIBCUDA_ORIG" | tr -d '\n' | \
             sed -e 's/00 00 00 f8 ff 00 00 00/00 00 00 f8 ff ff 00 00/g' \
                 -e 's/ /\\x/g') > "$PATCHED_LIB"
  if [ $? -ne 0 ]; then
    echo "✘ [ERROR] Failed to patch libcuda.so!"
    exit 1
  fi
  echo "✔ libcuda.so patch applied."
  echo "$CURRENT_HASH" > "$HASHFILE"
else
  echo "✔ libcuda.so is already patched and up to date."
fi
