#!/usr/bin/env bash
# yo.sh - Build a fakeroot inside real directory of $PWD with all needed libs + patched libcuda.so
# UNSTABLE/TESTING - DONT USE
# Run with bubblewrap + LD_PRELOAD + Vulkan/DXVK tracing

set -euo pipefail
shopt -s nullglob

# === CONFIG ===
BASE_DIR="$(realpath "$PWD")"
FAKE_ROOT="$BASE_DIR/usr"
CUSTOM_CUDA="$BASE_DIR/libcuda.patched.so"
REAL_LIB_DIRS=(/usr/lib /usr/lib64 /usr/lib32)
TARGET_SCRIPT="$1"
TRACING_LOG="$BASE_DIR/dxvk_trace.log"
WRAPPER="$BASE_DIR/wrapped.sh"

# === Checks ===
if [[ -z "$TARGET_SCRIPT" || ! -f "$TARGET_SCRIPT" ]]; then
  echo "Target not found: $TARGET_SCRIPT"
  exit 1
fi

echo "Target: $TARGET_SCRIPT"
echo "Using fakeroot base dir: $FAKE_ROOT"

# === Helper: Parse binaries from script ===
resolve_binaries_from_script() {
  local script="$1"
  grep -oP '(?<=\s|^)/[^\s|;]+' "$script" | grep -vE '^\s*$' | sort -u
}

# === Helper: Recursive ldd ===
declare -A libs_found=()
collect_all_deps() {
  local bin="$1"
  local -a queue=("$bin")
  declare -A seen=()

  while [[ ${#queue[@]} -gt 0 ]]; do
    local current="${queue[0]}"
    queue=("${queue[@]:1}")
    [[ ! -f "$current" || -n "${seen["$current"]+x}" ]] && continue
    seen["$current"]=1

    if file "$current" | grep -q "shared object"; then
      libs_found["$current"]=1
    fi

    ldd "$current" 2>/dev/null | awk '/=>/ {print $3}' | while read -r dep; do
      [[ -f "$dep" && -z "${seen["$dep"]+x}" ]] && {
        libs_found["$dep"]=1
        queue+=("$dep")
      }
    done
  done
}

# === Step 1: Collect top-level binaries ===
BINARIES=()
if head -n 1 "$TARGET_SCRIPT" | grep -qE '^#!.*(bash|sh|zsh)'; then
  echo "Script detected. Scanning for external binaries..."
  mapfile -t BINARIES < <(resolve_binaries_from_script "$TARGET_SCRIPT")
else
  echo "Binary detected."
  BINARIES=("$TARGET_SCRIPT")
fi

for bin in "${BINARIES[@]}"; do
  if [[ "$bin" =~ wine ]]; then
    dir=$(dirname "$bin")
    BINARIES+=("$dir/wineserver" "$dir/wine64" "$dir/wine-preloader" "$dir/wine64-preloader")
  fi
  collect_all_deps "$bin"
  echo "Found binary: $bin"
done

echo "Total unique libraries found: ${#libs_found[@]}"

# === Step 2: Build fakeroot dirs and copy libs ===
mkdir -p "$FAKE_ROOT"
for lib in "${!libs_found[@]}"; do
  for base in "${REAL_LIB_DIRS[@]}"; do
    if [[ "$lib" == $base/* ]]; then
      rel="${lib#"$base"/}"
      dst="$FAKE_ROOT${base}/$rel"
      mkdir -p "$(dirname "$dst")"
      if [[ ! -e "$dst" ]]; then
        cp -v "$lib" "$dst"
      fi
    fi
  done
done

# === Step 3: Copy patched libcuda.so ===
for dir in "$FAKE_ROOT/usr/lib" "$FAKE_ROOT/usr/lib64" "$FAKE_ROOT/usr/lib32"; do
  mkdir -p "$dir"
  if [[ -f "$CUSTOM_CUDA" ]]; then
    cp -v "$CUSTOM_CUDA" "$dir/libcuda.so"
    echo "Patched libcuda.so copied to $dir/"
  fi
done

# === Step 4: Create wrapper script ===
cat > "$WRAPPER" <<EOF
#!/bin/bash
export LD_PRELOAD="libcuda.so\${LD_PRELOAD:+:\$LD_PRELOAD}"
export DXVK_LOG_LEVEL=info
export DXVK_LOG_PATH="$TRACING_LOG"
exec "$BASE_DIR/$TARGET_SCRIPT" "\$@"
EOF
chmod +x "$WRAPPER"

# === Step 5: Run with bubblewrap ===
if ! command -v bwrap &>/dev/null; then
  echo "bubblewrap not installed. Install it first."
  exit 1
fi

echo "Launching with bubblewrap sandbox..."
exec bwrap \
  --ro-bind / / \
  --bind "$FAKE_ROOT/usr/lib" /usr/lib \
  --bind "$FAKE_ROOT/usr/lib64" /usr/lib64 \
  --bind "$FAKE_ROOT/usr/lib32" /usr/lib32 \
  --dev /dev \
  --proc /proc \
  --tmpfs /tmp \
  "$WRAPPER"
