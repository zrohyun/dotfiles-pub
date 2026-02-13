#!/usr/bin/env bash
set -euo pipefail

THEME_DIR=/dotfiles-pub/prompt-themes
TARGET_THEME="${DOTFILES_PUB_PROMPT_THEME:-minimal}"

case "$TARGET_THEME" in
  minimal|starship|powerline-go|liquidprompt) ;;
  *)
    echo "[dotfiles-pub] unknown theme: $TARGET_THEME"
    echo "  use: minimal, starship, powerline-go, liquidprompt"
    exit 1
    ;;
esac

apt-get update
apt-get install -y bash curl git sudo ca-certificates

if [[ "$TARGET_THEME" == "starship" ]]; then
  apt-get install -y starship || true
fi

if [[ "$TARGET_THEME" == "liquidprompt" ]]; then
  apt-get install -y liquidprompt || true
fi

if [[ "$TARGET_THEME" == "powerline-go" ]]; then
  if ! command -v powerline-go >/dev/null 2>&1; then
    curl -fsSL https://github.com/justjanne/powerline-go/releases/latest/download/powerline-go-linux-amd64 -o /tmp/powerline-go
    chmod +x /tmp/powerline-go
    mv /tmp/powerline-go /usr/local/bin/powerline-go
  fi
fi

cp "$THEME_DIR/$TARGET_THEME.bashrc" "$HOME/.bashrc"

echo "[dotfiles-pub] bootstrapped theme: $TARGET_THEME"
echo "[dotfiles-pub] theme: $TARGET_THEME ready"

echo "[dotfiles-pub] start interactive shell with: bash"
exec bash
