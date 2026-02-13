# dotfiles-pub bash prompt experiments (archived)

This folder is a backup of the old prompt theme experiments from `submodules/dotfiles-pub`.

## Archived files

- `prompt-themes/`
  - `minimal.bashrc`
  - `starship.bashrc`
  - `powerline-go.bashrc`
  - `liquidprompt.bashrc`
- `scripts/`
  - `prompt_theme_bootstrap.sh`
  - `prompt_theme_demo.sh`
- `README.dotfiles-pub.md`
  - A snapshot of the README at backup time

## Archived prompt candidates

- [Starship](https://github.com/starship/starship)
  - Multi-shell prompt engine, modular and fast
- [powerline-go](https://github.com/justjanne/powerline-go)
  - Lightweight Go-based powerline prompt
- [Liquid Prompt](https://github.com/nojhan/liquidprompt)
  - Bash-only prompt with detailed context

Current dotfiles-pub embeds the default prompt directly in `bashrc.template` instead of using these themes.

## Restore guide

If you want to try the archived themes again, copy them back:

```bash
cp -R /Users/ncai/.dotfiles/_hub/_data/bak/bash_prompt/prompt-themes /Users/ncai/.dotfiles/submodules/dotfiles-pub/
cp -R /Users/ncai/.dotfiles/_hub/_data/bak/bash_prompt/scripts /Users/ncai/.dotfiles/submodules/dotfiles-pub/
cp /Users/ncai/.dotfiles/_hub/_data/bak/bash_prompt/README.dotfiles-pub.md /Users/ncai/.dotfiles/submodules/dotfiles-pub/README.md
# in submodule root:
cp ./_hub/_data/bak/bash_prompt/README.dotfiles-pub.md ./README.md
```
