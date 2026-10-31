#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
# shellcheck source=lib/platform.sh
. "$ROOT/lib/platform.sh"

assert_equal() {
  if [ "$1" != "$2" ]; then
    printf 'Expected "%s", got "%s"\n' "$1" "$2" >&2
    exit 1
  fi
}

assert_equal x86_64-linux "$(DOTFILES_UNAME_S=Linux DOTFILES_UNAME_M=x86_64 DOTFILES_OS_ID=ubuntu dotfiles_system)"
assert_equal aarch64-linux "$(DOTFILES_UNAME_S=Linux DOTFILES_UNAME_M=aarch64 DOTFILES_OS_ID=ubuntu dotfiles_system)"
if DOTFILES_UNAME_S=Linux DOTFILES_OS_ID=debian dotfiles_os >/dev/null 2>&1; then
  printf '%s\n' 'Expected non-Ubuntu Linux to be rejected.' >&2
  exit 1
fi

for script in \
  "$ROOT/dev-env" \
  "$ROOT/lib/platform.sh" \
  "$ROOT/scripts/install-hermes.sh" \
  "$ROOT/scripts/set-default-shell.sh" \
  "$ROOT/tests/smoke.sh"
do
  bash -n "$script"
done

"$ROOT/dev-env" bootstrap --dry-run >/dev/null
"$ROOT/dev-env" --help >/dev/null
"$ROOT/dev-env" generations >/dev/null

printf '%s\n' 'Shell smoke tests passed.'
