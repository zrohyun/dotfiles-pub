# Repository Guidelines

## Project Structure & Module Organization
- `install.sh`: Main Linux-only installer; injects a managed block into `~/.bashrc`.
- `bashrc.template`: Template content inserted by `install.sh`.
- `scripts/`: Helper scripts for Docker-based testing (`run_docker_one_liner.sh`, `run_dotfiles_pub_single_clone.sh`).
- `.github/workflows/`: CI workflows (`install-test.yml`, `docker-build.yml`).
- `docs/issue/`: Issue notes and traceability writeups.
- `_hub/_data/bak/`: Archived prompt/theme experiments (reference only).
- `logs/ci/`: CI artifacts written by workflows.

## Build, Test, and Development Commands
- `./install.sh`: Run the installer locally (Linux only).
- `./scripts/run_dotfiles_pub_single_clone.sh`: Spins up an Ubuntu container, clones the repo, runs `install.sh`.
- `./scripts/run_docker_one_liner.sh`: One-liner Docker run that installs via the remote `install.sh`.
- `docker build -t dotfiles-pub .`: Build the Docker image locally.

## Coding Style & Naming Conventions
- Bash scripts use `#!/usr/bin/env bash` with `set -euo pipefail`.
- Indentation is two spaces in shell scripts; keep functions small and focused.
- Prefer explicit env var names and document them in `README.md` (e.g., `DOTFILES_PRIVATE_REPO`).
- Use clear, imperative names for scripts (e.g., `run_dotfiles_pub_single_clone.sh`).

## Testing Guidelines
- No unit test framework; validation is via CI workflows in `.github/workflows/`.
- CI: `Install Test` runs `install.sh` and verifies bashrc markers.
- CI: `Build and Push Docker Image` builds the Docker image and captures logs.
- When changing `install.sh` or `bashrc.template`, run `./install.sh` or the Docker scripts to verify behavior.

## Commit & Pull Request Guidelines
- Commit message convention (based on current git history):
- Prefer `type(scope): summary` for scoped changes. Common types: `fix`, `docs`, `chore`. Example: `fix(install): preserve aibt env under sudo`.
- For small, unscoped changes, an imperative sentence is acceptable (e.g., `Add GitHub Actions badges`, `Use curl install.sh in Dockerfile`).
- Keep commits small and scoped to one change.
- PRs should include a concise summary, relevant commands run (e.g., `./scripts/run_dotfiles_pub_single_clone.sh`), and links to related issues if any.

## Configuration & Security Notes
- Runtime overrides are environment variables documented in `README.md` (e.g., `DOTFILES_PRIVATE_REPO`, `DOTFILES_PRIVATE_DIR`).
- Private repo install uses GitHub CLI auth; fallback methods are documented but not auto-executed.
