[[ $- != *i* ]] && return

HISTCONTROL=ignoreboth
HISTSIZE=5000
HISTFILESIZE=10000
shopt -s histappend
shopt -s checkwinsize

if command -v powerline-go >/dev/null 2>&1; then
  if [[ -n "${PROMPT_COMMAND:-}" ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND}; powerline-go -error $? -shell bash"
  else
    PROMPT_COMMAND='powerline-go -error $? -shell bash'
  fi
else
  if command -v __git_ps1 >/dev/null 2>&1; then
    PS1='\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]$(__git_ps1 " (%s)")\$ '
  else
    PS1='\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ '
  fi
fi
