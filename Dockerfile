FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/root

WORKDIR /opt/dotfiles-pub
COPY . /opt/dotfiles-pub

# Run installer using local template to avoid network dependency.
RUN DOTFILES_PUB_TEMPLATE_PATH=/opt/dotfiles-pub/bashrc.template \
    bash /opt/dotfiles-pub/install.sh

CMD ["bash"]
