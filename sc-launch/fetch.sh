#!/usr/bin/env bash

(
  set -euo pipefail

  start_dir="$HOME/Games/star-citizen"
  tmpdir=$(mktemp -d)
  cleanup() { rm -rf "$tmpdir"; }
  trap cleanup EXIT

  git clone --no-checkout https://github.com/Vogelhaufen/priv-backup-pc.git "$tmpdir"
  cd "$tmpdir" || exit 1

  git sparse-checkout init
  git sparse-checkout set sc-launch/runtime
  git checkout

  src_dir="sc-launch/runtime"
  mkdir -p "$start_dir"

  shopt -s dotglob nullglob

  overwrite_all=false

  wrap_text() {
    local text="$1"
    local width=50
    local len=${#text}
    local start=0

    while [ $start -lt $len ]; do
      local segment="${text:start:width}"
      printf "*   %-50s*\n" "$segment"
      start=$((start + width))
    done
  }

  for file in "$src_dir"/* "$src_dir"/.[!.]* "$src_dir"/..?*; do
    [ -e "$file" ] || continue

    basefile=$(basename "$file")
    target="$start_dir/$basefile"

    if [ -e "$target" ] && [ "$overwrite_all" = false ]; then
      echo
      echo "*******************************************************"
      echo "*                                                     *"
      echo "*   ⚠  WARNING: File or directory exists:             *"
      wrap_text "$target"
      echo "*                                                     *"
      echo "*   This file already exists. Overwrite it?           *"
      echo "*                                                     *"
      echo "*   Type 'y' to overwrite this file only              *"
      echo "*   Type 'a' to overwrite ALL files without asking    *"
      echo "*   Type any other key to skip                         *"
      echo "*                                                     *"
      echo "*******************************************************"
      echo
      read -rp ">>> Your choice [y/N/a]: " answer
      case "$answer" in
        [yY]) ;;
        [aA]) overwrite_all=true ;;
        *) echo ">>> Skipping $target"; continue ;;
      esac
    fi

    if [ -d "$file" ]; then
      mkdir -p "$target"
      cp -a "$file"/. "$target"/
    else
      cp -a "$file" "$target"
    fi
  done

  if [ -f "$start_dir/startgame" ]; then
    chmod +x "$start_dir/startgame"
  fi

  echo "Copy finished successfully."
)
