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

## Bash prompt theme playground

### 조사한 오픈소스 Bash prompt

- `minimal` (local)
  - 기본 PS1 + git 브랜치/상태 표시
- `Starship` (https://github.com/starship/starship)
  - Rust로 만든 초경량 멀티셸 크로스-쉘 프롬프트
- `powerline-go` (https://github.com/justjanne/powerline-go)
  - Go로 만든 Powerline 스타일 Bash 프롬프트
- `Liquid Prompt` (https://github.com/nojhan/liquidprompt)
  - 배터리/업데이트/실행시간 등 컨텍스트를 보여주는 전통적인 Bash 프롬프트

### Docker로 테마 미리보기

```bash
cd /Users/ncai/.dotfiles/submodules/dotfiles-pub
./scripts/prompt_theme_demo.sh
```

- 메뉴에서 `minimal`, `starship`, `powerline-go`, `liquidprompt` 선택
- 선택 즉시 Ubuntu 컨테이너가 실행되고 `.bashrc`가 적용된 인터랙티브 쉘에 진입

### 직접 테마 지정 실행

```bash
./scripts/prompt_theme_demo.sh starship
./scripts/prompt_theme_demo.sh powerline-go
```

### 컨테이너 이미지/테마 강제 지정

```bash
export DOTFILES_PUB_DEMO_IMAGE=ubuntu:24.04
export DOTFILES_PUB_PROMPT_THEME=starship
./scripts/prompt_theme_demo.sh
```
