#!/bin/bash
# symlink everything, replace cuda
# works with eac
# !UNSTABLE/TESTING!

# Set your fake root
FAKE_ROOT="$HOME/fake-root/usr"

# List of real library directories
REAL_LIB_DIRS=(/usr/lib /usr/lib32 /usr/lib64)

for REAL_DIR in "${REAL_LIB_DIRS[@]}"; do
    RELATIVE_PATH=$(basename "$REAL_DIR")  # e.g., lib, lib32, lib64
    TARGET_BASE="$FAKE_ROOT/$RELATIVE_PATH"

    # Find all files under REAL_DIR
    find "$REAL_DIR" -type f | while read -r REAL_FILE; do
        BASENAME=$(basename "$REAL_FILE")
        
        # Skip libcuda.so and any versioned variant (libcuda.so.*, but not libcuda_static.a etc.)
        if [[ "$BASENAME" == libcuda.so* ]]; then
            continue
        fi

        # Get path relative to REAL_DIR
        REL_PATH="${REAL_FILE#$REAL_DIR/}"

        # Compute full target path in fake root
        TARGET_FILE="$TARGET_BASE/$REL_PATH"

        # Ensure the target directory exists
        mkdir -p "$(dirname "$TARGET_FILE")"

        # Create symlink
        ln -s "$REAL_FILE" "$TARGET_FILE"
    done
done
