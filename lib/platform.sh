#!/usr/bin/env bash

dotfiles_os() {
  local kernel os_id
  kernel="${DOTFILES_UNAME_S:-$(uname -s)}"
  if [ "$kernel" != Linux ]; then
    printf 'Unsupported operating system: %s (Ubuntu Linux is required)\n' \
      "$kernel" >&2
    return 1
  fi

  os_id="${DOTFILES_OS_ID:-}"
  if [ -z "$os_id" ] && [ -r /etc/os-release ]; then
    os_id="$(sed -nE 's/^ID="?([^"[:space:]]+)"?$/\1/p' /etc/os-release | head -n 1)"
  fi
  if [ "$os_id" != ubuntu ]; then
    printf 'Unsupported Linux distribution: %s (Ubuntu is required)\n' \
      "${os_id:-unknown}" >&2
    return 1
  fi

  printf '%s\n' ubuntu
}

dotfiles_system() {
  dotfiles_os >/dev/null
  case "${DOTFILES_UNAME_M:-$(uname -m)}" in
    x86_64|amd64) printf '%s\n' x86_64-linux ;;
    arm64|aarch64) printf '%s\n' aarch64-linux ;;
    *)
      printf 'Unsupported CPU architecture: %s\n' \
        "${DOTFILES_UNAME_M:-$(uname -m)}" >&2
      return 1
      ;;
  esac
}
