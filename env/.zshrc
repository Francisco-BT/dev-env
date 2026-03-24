# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
skip_global_compinit=1
ZSH_DISABLE_COMPFIX=true

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Settings for faster startup
DISABLE_UPDATE_PROMPT="true"
DISABLE_UNTRACKED_FILES_DIRTY="true" # Much faster git status in large repos

# History config
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8
source $ZSH/oh-my-zsh.sh
source ~/.zsh_profile
export PATH="$HOME/.local/bin:$PATH"

# Utility functions
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted" ;;
    esac
  fi
}

killport() { lsof -ti:$1 | xargs kill -9; }
findproc() { ps aux | grep -i $1; }

# Faster completion system
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Auto-start ssh-agent
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
fi

# fnm
if [ -d "/opt/homebrew/opt/fnm/bin" ]; then
  export PATH="/opt/homebrew/opt/fnm/bin:$PATH"
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

