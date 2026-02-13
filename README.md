# dotfiles-pub

[![Build and Push Docker Image](https://github.com/zrohyun/dotfiles-pub/actions/workflows/docker-build.yml/badge.svg)](https://github.com/zrohyun/dotfiles-pub/actions/workflows/docker-build.yml)
[![Install Test](https://github.com/zrohyun/dotfiles-pub/actions/workflows/install-test.yml/badge.svg)](https://github.com/zrohyun/dotfiles-pub/actions/workflows/install-test.yml)

A minimal Linux bootstrap that installs a managed `~/.bashrc` block and provides a helper to install private dotfiles.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/zrohyun/dotfiles-pub/main/install.sh | bash
source ~/.bashrc
drip
```

## What install.sh does

- Linux only (exits on non-Linux hosts)
- Backs up `~/.bashrc`
- Inserts a managed block (`DOTFILES_PUB_START/END`) idempotently
- Adds `dotfiles_private_install` and the `drip` alias
- Default private repo target: `zrohyun/dotfiles`

## Runtime variables (optional overrides)

- `DOTFILES_PRIVATE_REPO` (default: `zrohyun/dotfiles`)
- `DOTFILES_PRIVATE_DIR` (default: `~/.dotfiles`)
- `DOTFILES_PRIVATE_BRANCH` (default: `main`)
- `DOTFILES_EXPECTED_GH_USER` (default: `zrohyun`)

## tzdata prompts (aibt)

`aibt` can trigger tzdata prompts on some Ubuntu/Debian hosts. Use one of the following to avoid interaction.

Method 1: One-shot install with noninteractive TZ.

```bash
sudo DEBIAN_FRONTEND=noninteractive TZ=Asia/Seoul apt-get update
sudo DEBIAN_FRONTEND=noninteractive TZ=Asia/Seoul apt-get install -y vim curl git sudo
```

Method 2: Preconfigure tzdata, then run `aibt`.

```bash
sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
sudo dpkg-reconfigure -f noninteractive tzdata
aibt
```

If you want `aibt` itself to run noninteractively, set the env vars below.

```bash
DOTFILES_AIBT_NONINTERACTIVE=1 DOTFILES_TZ=Asia/Seoul aibt
```

## Auth policy

Default flow uses GitHub CLI:

1. Install `gh`
2. `gh auth login`
3. Ensure the authenticated user matches `DOTFILES_EXPECTED_GH_USER`

If checks pass, `drip` clones and runs the private `install.sh`.

## Fallback options (documentation only)

- PAT one-time input (`read -s`) for clone
- SSH deploy key (read-only) for clone

These fallback methods are intentionally not auto-executed by this repo.

## Bash prompt configuration

- `bashrc.template` now contains the prompt directly, so no external theme files are required.
- The prompt is git-aware and includes a compact status indicator.
- Archived prompt experiments live under `_hub/_data/bak/bash_prompt/` (see the README there for restore steps).

## TODO (private repo integration)

- [ ] GitHub Actions E2E test for private repo clone/install via key/token
- [ ] Local Docker tests covering private clone success/failure paths
- [ ] Document secret injection policy (secret names, read-only scope, rotation)
- [ ] Test matrix separating `gh` auth and key/token auth paths

## Single-repo Docker test

If you want to run the installer from a single cloned `dotfiles-pub` repo:

```bash
cd /path/to/dotfiles-pub
./scripts/run_dotfiles_pub_single_clone.sh
```

Override repo/branch via env vars if needed.

```bash
DOTFILES_PUB_REPO=https://github.com/zrohyun/dotfiles-pub.git \
DOTFILES_PUB_BRANCH=main \
./scripts/run_dotfiles_pub_single_clone.sh
```
