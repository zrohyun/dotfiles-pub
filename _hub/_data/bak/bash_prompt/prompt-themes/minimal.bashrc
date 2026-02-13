[[ $- != *i* ]] && return

# dotfiles-pub minimal prompt
HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend
shopt -s checkwinsize

__prompt_git_branch() {
  if ! command -v git >/dev/null 2>&1; then
    return
  fi
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return
  fi
  local branch=''
  branch="$(git branch --show-current 2>/dev/null || echo detached)"
  echo " (${branch})"
}

PS1='\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]$(__prompt_git_branch)\$ '
