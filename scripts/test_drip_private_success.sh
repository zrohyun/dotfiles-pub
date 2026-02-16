#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEEP_WORKDIR="${KEEP_WORKDIR:-0}"
WORKDIR="${WORKDIR:-$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-pub-success.XXXXXX")}"
WORK_HOME="$WORKDIR/home"
INSTALL_LOG="$WORKDIR/install.log"
DRIP_LOG="$WORKDIR/drip.log"

DOTFILES_PRIVATE_READ_TOKEN="${DOTFILES_PRIVATE_READ_TOKEN:-}"
DOTFILES_PRIVATE_REPO="${DOTFILES_PRIVATE_REPO:-zrohyun/dotfiles}"
DOTFILES_PRIVATE_BRANCH="${DOTFILES_PRIVATE_BRANCH:-main}"
DOTFILES_PRIVATE_DIR="${DOTFILES_PRIVATE_DIR:-$WORK_HOME/.dotfiles}"

cleanup() {
  if [[ "$KEEP_WORKDIR" == "1" ]]; then
    echo "[INFO] keeping workspace: $WORKDIR"
  else
    rm -rf "$WORKDIR"
  fi
}
trap cleanup EXIT

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

if [[ -z "$DOTFILES_PRIVATE_READ_TOKEN" ]]; then
  fail "DOTFILES_PRIVATE_READ_TOKEN is required."
fi

if ! command -v gh >/dev/null 2>&1; then
  fail "gh CLI is required."
fi

mkdir -p "$WORK_HOME"

echo "[INFO] running dotfiles-pub install.sh"
if ! HOME="$WORK_HOME" \
  DOTFILES_PUB_TEMPLATE_PATH="$ROOT_DIR/bashrc.template" \
  DOTFILES_PUB_ALLOW_NON_LINUX=1 \
  "$ROOT_DIR/install.sh" >"$INSTALL_LOG" 2>&1; then
  echo "[DEBUG] install output:"
  cat "$INSTALL_LOG" >&2
  fail "dotfiles-pub install.sh failed"
fi

echo "[INFO] authenticating gh"
if ! printf '%s' "$DOTFILES_PRIVATE_READ_TOKEN" | HOME="$WORK_HOME" gh auth login --hostname github.com --with-token >/dev/null 2>&1; then
  fail "gh auth login failed"
fi

if ! HOME="$WORK_HOME" gh auth status >/dev/null 2>&1; then
  fail "gh auth status failed after login"
fi

auth_user="$(HOME="$WORK_HOME" gh api user -q .login 2>/dev/null || true)"
if [[ -z "$auth_user" ]]; then
  fail "failed to resolve authenticated GitHub user"
fi

echo "[INFO] authenticated as: $auth_user"
echo "[INFO] running drip"

if ! HOME="$WORK_HOME" \
  DOTFILES_PRIVATE_REPO="$DOTFILES_PRIVATE_REPO" \
  DOTFILES_PRIVATE_BRANCH="$DOTFILES_PRIVATE_BRANCH" \
  DOTFILES_PRIVATE_DIR="$DOTFILES_PRIVATE_DIR" \
  DOTFILES_EXPECTED_GH_USER="$auth_user" \
  bash -ic 'drip' >"$DRIP_LOG" 2>&1; then
  echo "[DEBUG] drip output:"
  cat "$DRIP_LOG" >&2
  fail "drip failed"
fi

[[ -d "$DOTFILES_PRIVATE_DIR/.git" ]] || fail "private repo clone not found at $DOTFILES_PRIVATE_DIR"
[[ -f "$DOTFILES_PRIVATE_DIR/install.sh" ]] || fail "private install.sh missing after drip"
[[ -L "$WORK_HOME/.zshrc" ]] || fail "minimal install did not create ~/.zshrc symlink"

if [[ -d "$WORK_HOME/.oh-my-zsh" ]]; then
  fail "minimal install unexpectedly created ~/.oh-my-zsh"
fi

echo "[PASS] drip private success E2E completed."
