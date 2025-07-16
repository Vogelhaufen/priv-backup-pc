#!/usr/bin/env bash
(
  start_dir="$HOME/Games/star-citizen"
  tmpdir=$(mktemp -d) || { echo "Failed to create temp dir"; exit 1; }
  cleanup() { rm -rf "$tmpdir"; }
  trap cleanup EXIT

  git clone --no-checkout https://github.com/Vogelhaufen/priv-backup-pc.git "$tmpdir" || exit 1
  cd "$tmpdir" || exit 1
  git sparse-checkout init || exit 1
  git sparse-checkout set sc-launch/runtime || exit 1
  git checkout || exit 1

  echo "Checking for existing files in $start_dir that may be overwritten..."
  overwrite_all=false
  for file in sc-launch/runtime/* sc-launch/runtime/.*; do
    [ -e "$file" ] || continue
    basefile=$(basename "$file")
    target="$start_dir/$basefile"

    if [ -e "$target" ]; then
      if [ "$overwrite_all" = false ]; then
        read -p "File '$target' exists. Overwrite? [y/N/a=overwrite all] " answer
        case "$answer" in
          [yY]) ;;
          [aA]) overwrite_all=true ;;
          *) continue ;;
        esac
      fi
    fi

    cp -f "$file" "$target"
  done

  chmod +x "$start_dir/startgame"
