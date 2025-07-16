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

  for file in "$src_dir"/* "$src_dir"/.[!.]* "$src_dir"/..?*; do
    [ -e "$file" ] || continue

    basefile=$(basename "$file")
    target="$start_dir/$basefile"

    if [ -e "$target" ] && [ "$overwrite_all" = false ]; then
      read -rp "File or directory '$target' exists. Overwrite? [y/N/a=all] " answer
      case "$answer" in
        [yY]) ;;
        [aA]) overwrite_all=true ;;
        *) echo "Skipping $target"; continue ;;
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
