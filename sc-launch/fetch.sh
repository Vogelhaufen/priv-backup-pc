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

  mv sc-launch/runtime/* "$start_dir"/ || exit 1
  mv sc-launch/runtime/.* "$start_dir"/ 2>/dev/null || true

  chmod +x "$start_dir/startgame"
)
