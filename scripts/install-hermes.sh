#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
# shellcheck source=../versions.env
# shellcheck disable=SC1091
. "$ROOT/versions.env"

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=true
elif [ "$#" -ne 0 ]; then
  printf 'Usage: %s [--dry-run]\n' "$0" >&2
  exit 2
fi

case "$HERMES_COMMIT" in
  *[!0-9a-f]*|'') printf 'Invalid HERMES_COMMIT in versions.env.\n' >&2; exit 1 ;;
esac
if [ "${#HERMES_COMMIT}" -ne 40 ]; then
  printf 'HERMES_COMMIT must contain 40 hexadecimal characters.\n' >&2
  exit 1
fi

stamp="$HOME/.hermes/hermes-agent/install-stamp.json"
jq_bin="$(command -v jq 2>/dev/null || true)"
if [ -z "$jq_bin" ] && [ -x "$HOME/.nix-profile/bin/jq" ]; then
  jq_bin="$HOME/.nix-profile/bin/jq"
fi

installed_commit=""
if [ -f "$stamp" ] && [ -n "$jq_bin" ]; then
  installed_commit="$($jq_bin -r '.commit // empty' "$stamp")"
fi
if [ "$installed_commit" = "$HERMES_COMMIT" ]; then
  printf 'Hermes Agent %s is already installed.\n' "$HERMES_VERSION"
  exit 0
fi

installer_url="https://raw.githubusercontent.com/NousResearch/hermes-agent/$HERMES_COMMIT/scripts/install.sh"
if [ "$DRY_RUN" = true ]; then
  printf 'Would install Hermes Agent %s at commit %s.\n' \
    "$HERMES_VERSION" "$HERMES_COMMIT"
  exit 0
fi

curl_bin="$(command -v curl 2>/dev/null || true)"
if [ -z "$curl_bin" ] && [ -x "$HOME/.nix-profile/bin/curl" ]; then
  curl_bin="$HOME/.nix-profile/bin/curl"
fi
if [ -z "$curl_bin" ]; then
  printf '%s\n' 'curl is required to install Hermes Agent.' >&2
  exit 1
fi

installer_dir="$(mktemp -d "${TMPDIR:-/tmp}/hermes-install.XXXXXX")"
cleanup() { rm -rf "$installer_dir"; }
trap cleanup EXIT HUP INT TERM
installer="$installer_dir/install.sh"
"$curl_bin" --proto '=https' --tlsv1.2 -fsSL "$installer_url" -o "$installer"
bash "$installer" \
  --commit "$HERMES_COMMIT" \
  --channel stable \
  --hermes-home "$HOME/.hermes" \
  --non-interactive

printf 'Hermes Agent %s installed from pinned commit %s.\n' \
  "$HERMES_VERSION" "$HERMES_COMMIT"
