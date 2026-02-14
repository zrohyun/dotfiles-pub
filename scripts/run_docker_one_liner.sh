#!/usr/bin/env bash
set -euo pipefail

docker run --rm -it ubuntu:22.04 bash -lc "apt-get update && apt-get install -y curl && curl -fsSL https://raw.githubusercontent.com/zrohyun/dotfiles-pub/main/install.sh | bash && exec bash"
