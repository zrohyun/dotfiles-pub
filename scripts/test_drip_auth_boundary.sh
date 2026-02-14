#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEEP_WORKDIR="${KEEP_WORKDIR:-0}"
WORKDIR="${WORKDIR:-$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-pub-auth.XXXXXX")}"
LOG_DIR="$WORKDIR/logs"
mkdir -p "$LOG_DIR"

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

prepare_home() {
  local case_name="$1"
  local home_dir="$WORKDIR/$case_name/home"
  local install_log="$LOG_DIR/$case_name.install.log"

  mkdir -p "$home_dir"
  if ! HOME="$home_dir" DOTFILES_PUB_TEMPLATE_PATH="$ROOT_DIR/bashrc.template" \
    DOTFILES_PUB_ALLOW_NON_LINUX=1 \
    "$ROOT_DIR/install.sh" >"$install_log" 2>&1; then
    echo "[DEBUG] install output ($case_name):"
    cat "$install_log" >&2
    fail "$case_name: install.sh failed"
  fi

  echo "$home_dir"
}

run_expect_fail_contains() {
  local case_name="$1"
  local home_dir="$2"
  local path_value="$3"
  local expected="$4"
  local out="$LOG_DIR/$case_name.run.log"
  local rc=0

  set +e
  HOME="$home_dir" TEST_PATH="$path_value" DOTFILES_EXPECTED_GH_USER="zrohyun" \
    bash -ic 'PATH="$TEST_PATH"; export PATH; dotfiles_private_install' >"$out" 2>&1
  rc=$?
  set -e

  if [[ "$rc" -eq 0 ]]; then
    echo "[DEBUG] output ($case_name):"
    cat "$out" >&2
    fail "$case_name: expected non-zero exit"
  fi

  if ! grep -Fq "$expected" "$out"; then
    echo "[DEBUG] output ($case_name):"
    cat "$out" >&2
    fail "$case_name: expected output to contain: $expected"
  fi

  echo "[PASS] $case_name"
}

write_gh_stub_unauth() {
  local bin_dir="$1"
  cat >"$bin_dir/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "auth" && "${2:-}" == "status" ]]; then
  exit 1
fi

echo "unexpected gh invocation: $*" >&2
exit 99
EOF
  chmod +x "$bin_dir/gh"
}

write_gh_stub_mismatch() {
  local bin_dir="$1"
  cat >"$bin_dir/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "auth" && "${2:-}" == "status" ]]; then
  exit 0
fi

if [[ "${1:-}" == "api" && "${2:-}" == "user" ]]; then
  echo "someone-else"
  exit 0
fi

echo "unexpected gh invocation: $*" >&2
exit 99
EOF
  chmod +x "$bin_dir/gh"
}

echo "[INFO] workspace: $WORKDIR"

# Case 1) gh binary missing
home_no_gh="$(prepare_home "no-gh")" || fail "no-gh: failed to prepare HOME"
bin_no_gh="$WORKDIR/no-gh/bin"
mkdir -p "$bin_no_gh"
run_expect_fail_contains \
  "no-gh" \
  "$home_no_gh" \
  "$bin_no_gh" \
  "[dotfiles-pub] gh CLI is required."

# Case 2) gh exists but unauthenticated
home_unauth="$(prepare_home "gh-unauth")" || fail "gh-unauth: failed to prepare HOME"
bin_unauth="$WORKDIR/gh-unauth/bin"
mkdir -p "$bin_unauth"
write_gh_stub_unauth "$bin_unauth"
run_expect_fail_contains \
  "gh-unauth" \
  "$home_unauth" \
  "$bin_unauth:/usr/bin:/bin" \
  "[dotfiles-pub] gh is not authenticated."

# Case 3) gh authenticated but wrong account
home_mismatch="$(prepare_home "gh-user-mismatch")" || fail "gh-user-mismatch: failed to prepare HOME"
bin_mismatch="$WORKDIR/gh-user-mismatch/bin"
mkdir -p "$bin_mismatch"
write_gh_stub_mismatch "$bin_mismatch"
run_expect_fail_contains \
  "gh-user-mismatch" \
  "$home_mismatch" \
  "$bin_mismatch:/usr/bin:/bin" \
  "authenticated as 'someone-else' but expected 'zrohyun'"

echo "[PASS] drip auth boundary checks completed."
