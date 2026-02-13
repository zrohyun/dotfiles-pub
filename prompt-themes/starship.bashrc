[[ $- != *i* ]] && return

HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend
shopt -s checkwinsize

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
else
  PS1='\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\\$ '
fi
