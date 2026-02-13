#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "[dotfiles-pub] Linux only installer. Current OS: $(uname -s)"
  exit 1
fi

if [[ -z "${HOME:-}" ]]; then
  echo "[dotfiles-pub] HOME is not set."
  exit 1
fi

RC_FILE="${HOME}/.bashrc"
MARKER_START="# DOTFILES_PUB_START"
MARKER_END="# DOTFILES_PUB_END"

PUB_RAW_BASE="${DOTFILES_PUB_RAW_URL:-https://raw.githubusercontent.com/zrohyun/dotfiles-pub/main}"
TEMPLATE_URL="${PUB_RAW_BASE}/bashrc.template"

mkdir -p "${HOME}"
touch "$RC_FILE"

backup_file="${RC_FILE}.bak.$(date +%Y%m%d%H%M%S)"
cp "$RC_FILE" "$backup_file"

echo "[dotfiles-pub] backup: $backup_file"

# Remove previous managed block to keep installs idempotent.
tmp_clean="$(mktemp)"
awk -v s="$MARKER_START" -v e="$MARKER_END" '
$0==s {skip=1; next}
$0==e {skip=0; next}
!skip {print}
' "$RC_FILE" > "$tmp_clean"
mv "$tmp_clean" "$RC_FILE"

TEMPLATE_CONTENT=""
if command -v curl >/dev/null 2>&1; then
  TEMPLATE_CONTENT="$(curl -fsSL "$TEMPLATE_URL" || true)"
fi

if [[ -z "$TEMPLATE_CONTENT" ]]; then
  TEMPLATE_CONTENT='[[ $- != *i* ]] && return
HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend
shopt -s checkwinsize
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"'
fi

tmp_block="$(mktemp)"
{
  echo "$MARKER_START"
  echo "# Managed by dotfiles-pub install.sh"
  echo "# Remove this block to uninstall."
  echo
  printf '%s\n' "$TEMPLATE_CONTENT"
  cat <<'BLOCK'

# Private dotfiles bootstrap (defaults can be overridden before calling dpri)
export DOTFILES_PRIVATE_REPO="${DOTFILES_PRIVATE_REPO:-zrohyun/dotfiles}"
export DOTFILES_PRIVATE_DIR="${DOTFILES_PRIVATE_DIR:-$HOME/.dotfiles}"
export DOTFILES_PRIVATE_BRANCH="${DOTFILES_PRIVATE_BRANCH:-main}"
export DOTFILES_EXPECTED_GH_USER="${DOTFILES_EXPECTED_GH_USER:-zrohyun}"

apt_install_basic_tools() {
  local pkgs=(vim curl git sudo)

  if ! command -v apt >/dev/null 2>&1; then
    echo "[dotfiles-pub] apt is not available. This function is for Ubuntu/Debian only."
    return 1
  fi

  if command -v sudo >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y "${pkgs[@]}"
    return 0
  fi

  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "[dotfiles-pub] sudo is required to run aibt on non-root users."
    return 1
  fi

  apt update
  apt install -y "${pkgs[@]}"
}

alias aibt='apt_install_basic_tools'

dotfiles_private_install() {
  local repo="${DOTFILES_PRIVATE_REPO:-zrohyun/dotfiles}"
  local dir="${DOTFILES_PRIVATE_DIR:-$HOME/.dotfiles}"
  local branch="${DOTFILES_PRIVATE_BRANCH:-main}"
  local expected_user="${DOTFILES_EXPECTED_GH_USER:-zrohyun}"
  local current_user remote_url backup_dir

  if ! command -v gh >/dev/null 2>&1; then
    echo "[dotfiles-pub] gh CLI is required."
    if ! command -v sudo >/dev/null 2>&1; then
      echo "  sudo is not installed. Install sudo first."
    else
      echo "  Ubuntu/Debian: aibt && sudo apt install -y gh"
    fi
    echo "  Or run: aibt to install vim curl git sudo"
    echo "  Then run: gh auth login"
    return 1
  fi

  if ! gh auth status >/dev/null 2>&1; then
    echo "[dotfiles-pub] gh is not authenticated."
    echo "  Run: gh auth login"
    return 1
  fi

  current_user="$(gh api user -q .login 2>/dev/null || true)"
  if [[ -z "$current_user" ]]; then
    echo "[dotfiles-pub] failed to read current GitHub user via gh api user."
    return 1
  fi

  if [[ "$current_user" != "$expected_user" ]]; then
    echo "[dotfiles-pub] authenticated as '$current_user' but expected '$expected_user'."
    echo "  Switch account in gh, then retry."
    return 1
  fi

  if [[ -d "$dir/.git" ]]; then
    remote_url="$(git -C "$dir" remote get-url origin 2>/dev/null || true)"
    if [[ "$remote_url" == *"$repo"* ]]; then
      echo "[dotfiles-pub] existing private repo found at $dir, updating..."
      git -C "$dir" fetch origin "$branch" || true
      git -C "$dir" checkout "$branch" || true
      git -C "$dir" pull --ff-only origin "$branch" || true
    else
      backup_dir="${dir}.bak.$(date +%Y%m%d%H%M%S)"
      mv "$dir" "$backup_dir"
      echo "[dotfiles-pub] moved existing dir to $backup_dir"
      gh repo clone "$repo" "$dir" -- --branch "$branch" --depth 1
    fi
  elif [[ -e "$dir" ]]; then
    backup_dir="${dir}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dir" "$backup_dir"
    echo "[dotfiles-pub] moved existing path to $backup_dir"
    gh repo clone "$repo" "$dir" -- --branch "$branch" --depth 1
  else
    gh repo clone "$repo" "$dir" -- --branch "$branch" --depth 1
  fi

  if [[ ! -f "$dir/install.sh" ]]; then
    echo "[dotfiles-pub] install.sh not found in $dir"
    return 1
  fi

  echo "[dotfiles-pub] running private installer..."
  (
    cd "$dir"
    DOTFILES_INTERNAL_SOURCE=1 bash ./install.sh
  )
}

alias dpri='dotfiles_private_install'

# Fallback auth options (documentation only):
# 1) PAT one-time input: read -sr GITHUB_TOKEN; use it only for clone, then unset.
# 2) SSH deploy key: configure a read-only key for the private repo and clone via SSH.
BLOCK
  echo "$MARKER_END"
} > "$tmp_block"

echo >> "$RC_FILE"
cat "$tmp_block" >> "$RC_FILE"
rm -f "$tmp_block"

echo "[dotfiles-pub] Installed bootstrap block into $RC_FILE"
echo "[dotfiles-pub] Tip: run 'aibt' in shell to install basic tools (vim/curl/git/sudo)"
echo "[dotfiles-pub] Next: source ~/.bashrc && dpri"
