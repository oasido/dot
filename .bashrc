# ~/.bashrc — oasido's lightweight, interactive shell configuration

# 0 ── Exit early for non‑interactive shells ──────────────────
[[ $- != *i* ]] && return

# 1 ── Core environment variables ─────────────────────────────
export SCRIPTS="$HOME/.local/bin/scripts"
export PERSONAL="$HOME/Documents"
export SB="$HOME/sb"
export WORK="$HOME/work"
export UNI="$HOME/uni"
export NEOVIM_DIR="$HOME/.config/nvim"
export STARTUP="$HOME/.config/autostart"
export DOTFILES="$HOME/dot"
export BLITZ="/run/media/$(whoami)/blitz"
export EXTERNAL="/run/media/$(whoami)/External"

# Toolchains
export GO_ROOT="/usr/local/go/bin"
export CUDA_ROOT="/usr/local/cuda-12.9"
export TRT_ROOT="/usr/local/TensorRT-10.0.0.0"
export PNPM_HOME="$HOME/.local/share/pnpm"
export BUN_INSTALL="$HOME/.bun"
export RD_HOME="$HOME/.rd/bin"

if [ -x /usr/libexec/java_home ]; then
  export JAVA_HOME="$(/usr/libexec/java_home)"
elif [ -d /usr/lib64/jvm/java-23-openjdk ]; then
  export JAVA_HOME="/usr/lib64/jvm/java-23-openjdk"
fi

# 2 ── PATH ---------------------------------------------------
# Compose once; avoid duplicates
export PATH="$SCRIPTS:$GO_ROOT:$HOME/go/bin:$CUDA_ROOT/bin:$TRT_ROOT/bin:$PNPM_HOME:$BUN_INSTALL/bin:$RD_HOME:$PATH"
export LD_LIBRARY_PATH="$CUDA_ROOT/lib64:$TRT_ROOT/lib:$LD_LIBRARY_PATH"

# 3 ── Aliases & simple functions ────────────────────────────
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vi='nvim'
alias vim='nvim'
alias pn="pnpm"
alias lg="lazygit"
alias c='clear'
alias h="history | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
alias openports="ss -tulnpe"
alias sysupdate="sudo env ZYPP_CURL2=1 zypper ref && sudo zypper update && sudo env ZYPP_PCK_PRELOAD=1 zypper dup"
alias flatls="flatpak list --app --columns=size,name|sort -g | grep MB"
alias ff="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"
alias ffe="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' | xargs nvim"
alias airplay="uxplay -p 5100"
alias tb="nc termbin.com 9999"
alias rcloneweb="rclone rcd --rc-web-gui"

# cd shortcuts
alias home='cd ~'
alias work='cd $WORK'
alias pers='cd $PERSONAL'
alias uni='cd $UNI'
alias sb='cd $SB'
alias dot='cd $DOTFILES'
alias games="cd $EXTERNAL/Games"
alias es='vi $SCRIPTS'
alias ev='cd $HOME/.config/nvim && nvim'
alias ed='cd $HOME/dot && nvim'

# utils
alias topcpu='ps -eo pcpu,pid,user,args | sort -k1 -r | head'
alias openports='ss -tulnpe'
alias fpe="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' | xargs nvim"

# uni / C helpers
alias gcu='gcc -Wall -pedantic -ansi'

# reload
alias sbr='source ~/.bashrc'

# load personal/work aliases
if [ -f ~/.personal_aliases ]; then
  . ~/.personal_aliases
fi

if [ -f ~/.work_aliases ]; then
  . ~/.work_aliases
fi

# 4 ── Lazy‑load heavy helpers ───────────────────────────────
# --- nvm ----------------------------------------------------
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  command nvm "$@"
}

# --- conda --------------------------------------------------
conda() {
  unset -f conda
  if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
  fi
  command conda "$@"
}

# --- tmux-sessionizer ---------------------------------------
if [[ $- == *i* ]]; then
  bind '"\C-f":"tmux-sessionizer\n"'
fi

# --- bash‑completion (optional) -----------------------------
if [[ ! $BASH_COMPLETION_STAGE && -f /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

# 5 ── Prompt & colours ──────────────────────────────────────
# Simple coloured prompt with git branch (git‑prompt loads fast)
if [ -f /usr/share/git/git-prompt.sh ]; then
  . /usr/share/git/git-prompt.sh
fi
PS1='\[\e[38;5;250m\][\u@\h \w]\[\e[0m\]$(__git_ps1 " (%s)")\$ '
# PS1='\[\e[38;5;255m\][\[\e[38;5;33m\]\u\[\e[0m\]@\[\e[38;5;250m\]\h\[\e[0m\] \w\[\e[38;5;255m\]]\[\e[0m\]\\$ \[\e[38;5;34m\]${PS1_CMD1}\[\e[0m\]'

# 6 ── Misc touches ──────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export MAN_POSIXLY_CORRECT=1
HISTSIZE=10000
HISTFILESIZE=2000
shopt -s histappend
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
shopt -s checkwinsize

# Coloured GCC output
export GCC_COLORS='error=01;31:warning=01;35:note=01;36'
