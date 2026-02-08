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
- `DOTFILES_PRIVATE_DIR` (default: `~/.dotfiles`)
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

## TODO (private 연동 테스트)

- [ ] GitHub Actions에서 `key/token` 기반으로 private repo(`zrohyun/dotfiles`) clone/install E2E 검증
- [ ] local Docker 테스트에서 `key/token` 기반 private clone 경로를 재현하고 성공/실패 케이스 점검
- [ ] secret 주입 정책 문서화: Actions Secret 이름, 권한 범위(read-only), rotation 주기
- [ ] `gh` 인증 경로와 `key/token` 경로를 분리한 테스트 매트릭스 구성
