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

## Bash prompt configuration

- `bashrc.template` now contains the prompt directly, so no external prompt theme files are required.
- Prompt is git-aware and adds a compact status indicator for a cleaner default experience.
- If you want to test previously explored themes, archived files are in:
  - `_hub/_data/bak/bash_prompt/prompt-themes`
  - `_hub/_data/bak/bash_prompt/scripts`

### Restore archived prompt experiments

If you want to try the archived themes again, copy them back from backup:

```bash
cp -R /Users/ncai/.dotfiles/_hub/_data/bak/bash_prompt/prompt-themes /Users/ncai/.dotfiles/submodules/dotfiles-pub/
cp -R /Users/ncai/.dotfiles/_hub/_data/bak/bash_prompt/scripts /Users/ncai/.dotfiles/submodules/dotfiles-pub/
```

## TODO (private 연동 테스트)

- [ ] GitHub Actions에서 `key/token` 기반으로 private repo(`zrohyun/dotfiles`) clone/install E2E 검증
- [ ] local Docker 테스트에서 `key/token` 기반 private clone 경로를 재현하고 성공/실패 케이스 점검
- [ ] secret 주입 정책 문서화: Actions Secret 이름, 권한 범위(read-only), rotation 주기
- [ ] `gh` 인증 경로와 `key/token` 경로를 분리한 테스트 매트릭스 구성

## Docker 단일 리포지토리 테스트

단일 `dotfiles-pub` 리포지토리를 clone한 상태에서 로컬에서 바로 실행해보려면 다음 스크립트를 사용합니다.

```bash
cd /path/to/dotfiles-pub
./scripts/run_dotfiles_pub_single_clone.sh
```

필요한 경우 repo/branch를 환경변수로 바꿔서 실행할 수 있습니다.

```bash
DOTFILES_PUB_REPO=https://github.com/zrohyun/dotfiles-pub.git \
DOTFILES_PUB_BRANCH=main \
./scripts/run_dotfiles_pub_single_clone.sh
```
