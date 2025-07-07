#!/bin/bash
# fakelib env with symlinks, replace libcuda.so
# export LD_LIBRARY_PATH=$HOME/playground/usr/lib:$HOME/playground/usr/lib64:$HOME/playground/usr/lib32
# neeeds parallel for faster execution
# !UNSTABLE/TESTING!

set -euo pipefail

FAKE_ROOT="$HOME/fake-root/usr"
REAL_LIB_DIRS=(/usr/lib /usr/lib32 /usr/lib64)

mkdir -p "$FAKE_ROOT"

for REAL_DIR in "${REAL_LIB_DIRS[@]}"; do
  REL_BASE=$(basename "$REAL_DIR")
  TARGET_BASE="$FAKE_ROOT/$REL_BASE"
  mkdir -p "$TARGET_BASE"

  echo "Processing $REAL_DIR → $TARGET_BASE"

  # create directories first
  find "$REAL_DIR" -type d | sed "s|^$REAL_DIR|$TARGET_BASE|" | xargs -P 64 -I{} mkdir -p {}

  # create symlinks for files excluding libcuda.so*
  find "$REAL_DIR" -type f ! -name 'libcuda.so*' | \
  parallel --jobs 128 --no-notice --bar '
    SRC="{}"
    DST="'"$TARGET_BASE"'/${SRC#'"$REAL_DIR"'/}"
    ln -sf "$SRC" "$DST"
  '
done

echo "Done!"
