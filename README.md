# dotfiles-pub

Linux bootstrap for loading a minimal `~/.bashrc` block and then installing private dotfiles.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/zrohyun/dotfiles-pub/main/install.sh | bash
source ~/.bashrc
dpri
```

## What install.sh does

- Works on Linux only (exits on non-Linux)
- Backs up `~/.bashrc`
- Installs a managed bootstrap block (`DOTFILES_PUB_START/END`) idempotently
- Adds `dotfiles_private_install` and alias `dpri`
- Default private target repo: `zrohyun/dotfiles`

## Runtime variables (optional overrides)

- `DOTFILES_PRIVATE_REPO` (default: `zrohyun/dotfiles`)
- `DOTFILES_PRIVATE_DIR` (default: `~/.dotfiles-private`)
- `DOTFILES_PRIVATE_BRANCH` (default: `main`)
- `DOTFILES_EXPECTED_GH_USER` (default: `zrohyun`)

## Auth policy

Default flow uses GitHub CLI:

1. `gh` installed
2. `gh auth login`
3. authenticated user matches `DOTFILES_EXPECTED_GH_USER`

If checks pass, `dpri` clones and runs private `install.sh`.

## Fallback options (documentation only)

- PAT one-time input (`read -s`) for clone
- SSH Deploy Key (read-only) for clone

These fallback methods are intentionally not auto-executed by this repo.
