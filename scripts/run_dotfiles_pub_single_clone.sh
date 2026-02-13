#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-ubuntu:24.04}"
CONTAINER_NAME="${CONTAINER_NAME:-dotfiles-pub-single-clone}"
DOTFILES_PUB_REPO="${DOTFILES_PUB_REPO:-https://github.com/zrohyun/dotfiles-pub.git}"
DOTFILES_PUB_BRANCH="${DOTFILES_PUB_BRANCH:-main}"
DOTFILES_PUB_DIR="${DOTFILES_PUB_DIR:-/root/.dotfiles-pub}"

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] docker command not found."
  exit 1
fi

if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  docker rm -f "$CONTAINER_NAME" >/dev/null
fi

docker run -d --name "$CONTAINER_NAME" "$IMAGE" sleep infinity >/dev/null

docker exec \
  -e DEBIAN_FRONTEND=noninteractive \
  "$CONTAINER_NAME" \
  bash -lc 'apt-get update >/dev/null && apt-get install -y git curl ca-certificates >/dev/null'

docker exec \
  -e DOTFILES_PUB_REPO="$DOTFILES_PUB_REPO" \
  -e DOTFILES_PUB_BRANCH="$DOTFILES_PUB_BRANCH" \
  -e DOTFILES_PUB_DIR="$DOTFILES_PUB_DIR" \
  "$CONTAINER_NAME" \
  bash -lc 'git clone --depth=1 -b "$DOTFILES_PUB_BRANCH" "$DOTFILES_PUB_REPO" "$DOTFILES_PUB_DIR"'

docker exec \
  -e DOTFILES_PUB_DIR="$DOTFILES_PUB_DIR" \
  "$CONTAINER_NAME" \
  bash -lc 'cd "$DOTFILES_PUB_DIR" && DOTFILES_PUB_TEMPLATE_PATH="$DOTFILES_PUB_DIR/bashrc.template" ./install.sh'

echo "[OK] container ready: $CONTAINER_NAME"
echo "[OK] inspect: docker exec -it -e TERM=xterm-256color -e COLORTERM=truecolor $CONTAINER_NAME bash"
