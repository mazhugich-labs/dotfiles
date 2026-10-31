# Reproducible Ubuntu development environment

This repository manages the daily tools and authored configuration for this
account with Nix and standalone Home Manager. `flake.lock` records the exact
Nix package graph. `versions.env` pins the Nix bootstrap installer with
per-architecture SHA-256 checksums and pins the supported Hermes installer to
an exact release commit. Rebuilding does not silently change versions;
updating is a separate, deliberate operation.

## Managed tools

- WezTerm and Hack Nerd Font
- Neovim and its plugins
- Herdr
- OpenAI Codex CLI
- Hermes Agent (official installer, pinned to an exact stable release commit)
- Zsh, autosuggestions, syntax highlighting, and Starship
- Git, ripgrep, fd, fzf, jq, lazygit, curl, and ShellCheck

The application configs in `home/` are linked directly into the home directory.
Edit those repository files normally; no rebuild is needed for most config-only
changes. Zsh and package configuration live in `modules/home.nix` and do require
a rebuild.

Codex uses its defaults, so this repository installs the CLI but does not manage
`~/.codex/config.toml`. Codex authentication, preferences, project trust,
history, logs, and other mutable application state stay in `~/.codex`.
Hermes credentials, memory, sessions, plugins, and self-managed `config.yaml`
stay in `~/.hermes`. They are personal/runtime data, not dotfiles. Its official
installer and updater preserve that directory.

## Fresh Ubuntu bootstrap

Install Git, clone this repository, and enter it. If the login name is not
`mazhugich`, change `username` in `settings.nix`, then run:

```sh
./dev-env bootstrap --dry-run
./dev-env bootstrap
```

The command installs a pinned, checksum-verified Nix installer when necessary,
creates `~/.dotfiles` pointing to this checkout, applies the locked Home Manager
generation, and makes the managed Zsh the login shell. Nix installation and the
shell change request `sudo`. Existing files that collide with managed paths are
moved to timestamped `*.hm-backup-*` paths by Home Manager.

Log out and back in after the first bootstrap. Sign in to Codex normally. Hermes
will reuse an existing `~/.hermes`; on a new machine, run its normal setup once.

## Daily commands

Apply package or Zsh changes without changing versions:

```sh
./dev-env rebuild
```

Update all managed tools, rebuild, and update Neovim plugins:

```sh
./dev-env update
```

The update advances the Hermes release in `versions.env`, refreshes
`flake.lock`, and may change `home/.config/nvim/lazy-lock.json`. Review and
commit those files: they are the reproducible version record used by the next
machine.

Inspect versions and validate the setup:

```sh
./dev-env versions
./dev-env check
```

List saved Home Manager generations or return to the previous one:

```sh
./dev-env generations
./dev-env rollback
```

Rollback restores the previous Home Manager package generation and declarative
shell settings. The application configs under `home/` are live repository links,
and Hermes is installed separately, so a complete rollback of those parts means
restoring the desired Git revision and running `./dev-env rebuild`.

Do not run `herdr update` or `hermes update`; `./dev-env update` is the common
update path and records the result for the next machine.

## Adding something

- Add a package to `home.packages` in `modules/home.nix`.
- Put authored application config under `home/` and add an out-of-store link in
  `modules/home.nix`.
- Run `./dev-env rebuild`, test it, and commit the changes.

Because configs are live links, do not put API keys or auth files under `home/`.
Only Ubuntu on x86_64 or aarch64 is supported by the bootstrap script.
