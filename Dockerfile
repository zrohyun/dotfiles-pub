FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/root

# Option 1 (default): curl main branch install.sh
# Option 2 (commented): curl with a fixed commit SHA via build arg
#   ARG DOTFILES_PUB_SHA
#   RUN curl -fsSL "https://raw.githubusercontent.com/zrohyun/dotfiles-pub/${DOTFILES_PUB_SHA}/install.sh" | bash
# Option 3 (commented): curl with a fixed release tag via build arg
#   ARG DOTFILES_PUB_TAG
#   RUN curl -fsSL "https://raw.githubusercontent.com/zrohyun/dotfiles-pub/${DOTFILES_PUB_TAG}/install.sh" | bash

RUN apt-get update && apt-get install -y curl

RUN curl -fsSL "https://raw.githubusercontent.com/zrohyun/dotfiles-pub/main/install.sh" | bash

CMD ["bash"]
