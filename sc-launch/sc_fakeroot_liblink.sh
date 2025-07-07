#!/bin/bash
# fakelib env with symlinks, replace libcuda.so
# export LD_LIBRARY_PATH=$HOME/playground/usr/lib:$HOME/playground/usr/lib64:$HOME/playground/usr/lib32
# neeeds parallel for faster execution
# !UNSTABLE/TESTING!

set -euo pipefail

FAKE_ROOT="$HOME/playground/usr"
REAL_LIB_DIRS=(/usr/lib /usr/lib32 /usr/lib64)

mkdir -p "$FAKE_ROOT"

for REAL_DIR in "${REAL_LIB_DIRS[@]}"; do
  REL_BASE=$(basename "$REAL_DIR")
  TARGET_BASE="$FAKE_ROOT/$REL_BASE"
  mkdir -p "$TARGET_BASE"

  echo "Processing $REAL_DIR → $TARGET_BASE"

  # 1) Create all directories in target in parallel
  find "$REAL_DIR" -type d | \
    sed "s|^$REAL_DIR|$TARGET_BASE|" | \
    xargs -P 200 -I{} mkdir -p {}

  # 2) Create symlinks for files excluding libcuda.so* in parallel
  find "$REAL_DIR" -type f ! -name 'libcuda.so*' | \
    parallel --jobs 200 --no-notice --bar '
      SRC="{}"
      DST="'"$TARGET_BASE"'/${SRC#'"$REAL_DIR"'/}"
      ln -sf "$SRC" "$DST"
    '
done

echo "All done!"
