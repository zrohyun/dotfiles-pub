# dotfiles-pub

[![Build and Push Docker Image](https://github.com/zrohyun/dotfiles-pub/actions/workflows/docker-build.yml/badge.svg)](https://github.com/zrohyun/dotfiles-pub/actions/workflows/docker-build.yml)
[![Install Test](https://github.com/zrohyun/dotfiles-pub/actions/workflows/install-test.yml/badge.svg)](https://github.com/zrohyun/dotfiles-pub/actions/workflows/install-test.yml)
[![Drip Private Success E2E](https://github.com/zrohyun/dotfiles-pub/actions/workflows/drip-private-success-e2e.yml/badge.svg)](https://github.com/zrohyun/dotfiles-pub/actions/workflows/drip-private-success-e2e.yml)

A minimal Linux bootstrap that installs a managed `~/.bashrc` block and provides a helper to install private dotfiles.

## Quick Start

```bash
cd submodules/dotfiles-pub
./install.sh
source ~/.bashrc
aboot
aigh
gh auth login
drip
cd ~/.dotfiles
make setup-core
make setup-dev
make setup-extra
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

## Install policy (simplified)

For simplicity, this repo does not pin `install.sh` to a commit SHA or verify its hash by default. It always fetches the latest `main` version.

## tzdata prompts (aboot)

`aboot` can trigger tzdata prompts on some Ubuntu/Debian hosts. Use one of the following to avoid interaction.

Method 1: One-shot install with noninteractive TZ.

```bash
sudo DEBIAN_FRONTEND=noninteractive TZ=Asia/Seoul apt-get update
sudo DEBIAN_FRONTEND=noninteractive TZ=Asia/Seoul apt-get install -y vim curl git sudo
```

Method 2: Preconfigure tzdata, then run `aboot`.

```bash
sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
sudo dpkg-reconfigure -f noninteractive tzdata
aboot
```

If you want `aboot` itself to run noninteractively, set the env vars below.

```bash
DOTFILES_AIBT_NONINTERACTIVE=1 DOTFILES_TZ=Asia/Seoul aboot
```

## gh install (aigh)

```bash
aigh
```

## Auth policy

Default flow uses GitHub CLI:

1. Install `gh`
2. `gh auth login`
3. Ensure the authenticated user matches `DOTFILES_EXPECTED_GH_USER`

If checks pass, `drip` clones and runs the private `install.sh` (minimal only).
Then continue staged setup from the private repo with `make setup-core`, `make setup-dev`, and `make setup-extra`.

## Fallback options (documentation only)

- PAT one-time input (`read -s`) for clone
- SSH deploy key (read-only) for clone

These fallback methods are intentionally not auto-executed by this repo.

## Bash prompt configuration

- `bashrc.template` now contains the prompt directly, so no external theme files are required.
- The prompt is git-aware and includes a compact status indicator.
- Archived prompt experiments live under `_hub/_data/bak/bash_prompt/` (see the README there for restore steps).

## TODO (private repo integration)

- [x] `drip` auth boundary smoke test (`gh` missing/unauthenticated/user mismatch)
- [x] GitHub Actions E2E test for private repo clone/install via token
- [ ] Local Docker tests covering private clone success/failure paths
- [x] Document secret injection policy (secret names, read-only scope, rotation)
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

## Auth boundary smoke test

Validate `drip` authentication guard rails (`gh missing`, `gh unauthenticated`, `gh user mismatch`):

```bash
./scripts/test_drip_auth_boundary.sh
```

## Private success E2E (GitHub Actions)

This E2E validates `gh auth` success path: `drip -> private clone -> private minimal install`.

1. Add repository secret `DOTFILES_PRIVATE_READ_TOKEN` (read-only access to the private dotfiles repo).
2. Run workflow `Drip Private Success E2E` (`workflow_dispatch`) with optional inputs:
   - `private_repo` (default: `zrohyun/dotfiles`)
   - `private_branch` (default: `main`)
3. The workflow also listens on `push`/`pull_request` for installer/auth test path changes and auto-skips when the secret is not configured.

Local run:

```bash
DOTFILES_PRIVATE_READ_TOKEN=*** ./scripts/test_drip_private_success.sh
```
