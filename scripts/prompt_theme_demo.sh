#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="${DOTFILES_PUB_DEMO_IMAGE:-ubuntu:22.04}"

echo "dotfiles-pub bashrc theme playground"
echo "1) minimal"
echo "2) starship"
echo "3) powerline-go"
echo "4) liquidprompt"

themes=(minimal starship powerline-go liquidprompt)

if [[ "${1-}" == "--help" ]]; then
  echo "Usage: $0 [theme]"
  echo "Themes: ${themes[*]}"
  exit 0
fi

if [[ $# -ge 1 ]]; then
  selected="$1"
else
  read -r -p "선택하세요 [1-4]: " selected
fi

case "$selected" in
  1|minimal) selected=minimal ;;
  2|starship) selected=starship ;;
  3|powerline-go) selected=powerline-go ;;
  4|liquidprompt) selected=liquidprompt ;;
  *)
    echo "[dotfiles-pub] invalid theme: $selected"
    echo "available: 1|minimal 2|starship 3|powerline-go 4|liquidprompt"
    exit 1
    ;;
esac

if ! command -v docker >/dev/null 2>&1; then
  echo "[dotfiles-pub] docker is required to run this command."
  exit 1
fi

docker run --rm -it \
  -v "$ROOT_DIR:/dotfiles-pub:ro" \
  -e "DOTFILES_PUB_PROMPT_THEME=$selected" \
  "$IMAGE" \
  bash -lc "bash /dotfiles-pub/scripts/prompt_theme_bootstrap.sh"
