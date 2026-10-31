#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=true
elif [ "$#" -ne 0 ]; then
  printf 'Usage: %s [--dry-run]\n' "$0" >&2
  exit 2
fi

zsh_path=""
for candidate in \
  "$HOME/.local/state/nix/profiles/home-manager/home-path/bin/zsh" \
  "$HOME/.nix-profile/bin/zsh"
do
  if [ -x "$candidate" ]; then
    zsh_path="$candidate"
    break
  fi
done

if [ -z "$zsh_path" ]; then
  printf '%s\n' 'Zsh is missing; apply the Home Manager configuration first.' >&2
  exit 1
fi

if [ "$DRY_RUN" = true ]; then
  printf 'Would register %s in /etc/shells and set it as the login shell.\n' "$zsh_path"
  exit 0
fi

if ! grep -Fqx "$zsh_path" /etc/shells 2>/dev/null; then
  printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null
fi

current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
if [ "$current_shell" = "$zsh_path" ]; then
  printf 'Zsh is already the login shell: %s\n' "$zsh_path"
  exit 0
fi

sudo chsh -s "$zsh_path" "$(id -un)"
printf 'Login shell changed to %s. Log out and back in once.\n' "$zsh_path"

