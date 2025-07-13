#!/usr/bin/env bash
# Find the real 64-bit libcuda.so
echo "============== Locating 64-bit libcuda.so ============="

LIBCUDA_ORIG=""
LIB_SEARCH_PATHS=(
  /usr/lib
  /usr/lib64
  /usr/lib/x86_64-linux-gnu
  /lib
  /lib64
  /lib/x86_64-linux-gnu
  /usr/local/lib
  /usr/local/lib64
)

for dir in "${LIB_SEARCH_PATHS[@]}"; do
  for symlink in $(find "$dir" -type l -name "libcuda.so" 2>/dev/null); do
    resolved=$(realpath "$symlink")
    if [ -f "$resolved" ] && file "$resolved" | grep -q "ELF 64-bit"; then
      LIBCUDA_ORIG="$resolved"
      break 2
    fi
  done
done

if [ -z "$LIBCUDA_ORIG" ]; then
  echo "✘ No 64-bit libcuda.so found!"
  exit 1
else
  echo "✔ Found 64-bit libcuda.so at: $LIBCUDA_ORIG"
fi

# Mount Patched libcuda.so
PATCHED_CUDA=$HOME/Games/star-citizen/libcuda.patched.so

echo ""
echo "======= Mouting $PATCHED_CUDA to $LIBCUDA_ORIG ========"

while mount | grep -q "$LIBCUDA_ORIG"; do
    sudo umount "$LIBCUDA_ORIG"

    read -rp "Still mounted. Try again? (y/n): " answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
        echo "Cancelling unmount attempts."
        break
    fi
done

while mount | grep -q "$PATCHED_CUDA"; do
    sudo umount "$PATCHED_CUDA"

    read -rp "Still mounted. Try again? (y/n): " answer2
    if [[ "$answer2" != "y" && "$answer2" != "Y" ]]; then
        echo "Cancelling unmount attempts."
        break
    fi
done


sudo mount --bind $PATCHED_CUDA $(realpath $LIBCUDA_ORIG)
sleep 1
mount | grep -i cuda
