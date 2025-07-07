#!/bin/bash
# fakelib env with symlinks, replace libcuda.so
# export LD_LIBRARY_PATH=$HOME/playground/usr/lib:$HOME/playground/usr/lib64:$HOME/playground/usr/lib32
# neeeds parallel for faster execution .. its fast... really fast
# be careful - we need root for this
# !UNSTABLE/TESTING!

set -euo pipefail

# Config
FAKE_ROOT="$HOME/fake-root/usr"
REAL_LIB_DIRS=(/usr/lib /usr/lib32 /usr/lib64)

# Dependencies
command -v parallel >/dev/null || { echo "GNU parallel is required"; exit 1; }

# Start
echo "Creating fake root at: $FAKE_ROOT"
mkdir -p "$FAKE_ROOT"

for REAL_DIR in "${REAL_LIB_DIRS[@]}"; do
  REL_BASE=$(basename "$REAL_DIR")
  TARGET_BASE="$FAKE_ROOT/$REL_BASE"
  echo "→ Processing $REAL_DIR → $TARGET_BASE"
  mkdir -p "$TARGET_BASE"

  # Mirror directory structure
  find "$REAL_DIR" -type d 2>/dev/null | sed "s|^$REAL_DIR|$TARGET_BASE|" | \
    parallel --no-notice --bar mkdir -p

  # Create symlinks (skip libcuda*)
  find "$REAL_DIR" -type f ! -name 'libcuda.so*' 2>/dev/null | \
    parallel --no-notice --bar --jobs 128 '
      SRC="{}"
      DST="'"$TARGET_BASE"'/${SRC#'"$REAL_DIR"'/}"
      mkdir -p "$(dirname "$DST")"
      ln -sf "$SRC" "$DST"
    '
done

echo "✅ Done. Symlinks created in $FAKE_ROOT"
