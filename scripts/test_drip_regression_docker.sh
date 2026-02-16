#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

IMAGE="${IMAGE:-ubuntu:24.04}"
CONTAINER_NAME="${CONTAINER_NAME:-dotfiles-pub-drip-regression}"
KEEP_CONTAINER="${KEEP_CONTAINER:-0}"
REQUIRE_PRIVATE_SUCCESS="${REQUIRE_PRIVATE_SUCCESS:-1}"

DOTFILES_PRIVATE_READ_TOKEN="${DOTFILES_PRIVATE_READ_TOKEN:-}"
DOTFILES_PRIVATE_REPO="${DOTFILES_PRIVATE_REPO:-zrohyun/dotfiles}"
DOTFILES_PRIVATE_BRANCH="${DOTFILES_PRIVATE_BRANCH:-main}"

log() {
  echo "[INFO] $*"
}

pass() {
  echo "[PASS] $*"
}

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

cleanup() {
  if [[ "$KEEP_CONTAINER" == "1" ]]; then
    log "keeping container: $CONTAINER_NAME"
    return 0
  fi

  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

if ! command -v docker >/dev/null 2>&1; then
  fail "docker command not found."
fi

if [[ "$REQUIRE_PRIVATE_SUCCESS" == "1" && -z "$DOTFILES_PRIVATE_READ_TOKEN" ]]; then
  fail "DOTFILES_PRIVATE_READ_TOKEN is required when REQUIRE_PRIVATE_SUCCESS=1."
fi

log "starting container: $CONTAINER_NAME ($IMAGE)"
docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
docker run -d \
  --name "$CONTAINER_NAME" \
  -v "$ROOT_DIR:/workspace/dotfiles-pub:ro" \
  -w /workspace/dotfiles-pub \
  "$IMAGE" \
  sleep infinity >/dev/null

log "installing base packages"
docker exec -e DEBIAN_FRONTEND=noninteractive "$CONTAINER_NAME" bash -lc '
  apt-get update >/dev/null
  apt-get install -y bash git curl ca-certificates >/dev/null
'

log "running auth boundary regression (failure cases)"
docker exec "$CONTAINER_NAME" bash -lc '
  cd /workspace/dotfiles-pub
  bash ./scripts/test_drip_auth_boundary.sh
'
pass "auth boundary regression completed"

if [[ -n "$DOTFILES_PRIVATE_READ_TOKEN" ]]; then
  log "installing gh for private success path"
  docker exec -e DEBIAN_FRONTEND=noninteractive "$CONTAINER_NAME" bash -lc '
    apt-get update >/dev/null
    apt-get install -y gh >/dev/null
  '

  log "running private success regression (drip -> private minimal install)"
  docker exec \
    -e DOTFILES_PRIVATE_READ_TOKEN="$DOTFILES_PRIVATE_READ_TOKEN" \
    -e DOTFILES_PRIVATE_REPO="$DOTFILES_PRIVATE_REPO" \
    -e DOTFILES_PRIVATE_BRANCH="$DOTFILES_PRIVATE_BRANCH" \
    "$CONTAINER_NAME" \
    bash -lc '
      cd /workspace/dotfiles-pub
      bash ./scripts/test_drip_private_success.sh
    '
  pass "private success regression completed"
else
  log "DOTFILES_PRIVATE_READ_TOKEN is empty. Skipping private success regression."
  log "Set REQUIRE_PRIVATE_SUCCESS=0 to allow this skip."
  if [[ "$REQUIRE_PRIVATE_SUCCESS" == "1" ]]; then
    fail "private success regression skipped while REQUIRE_PRIVATE_SUCCESS=1."
  fi
fi

pass "docker regression finished: dotfiles-pub -> drip path"
