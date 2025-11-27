# ~/.bashrc — oasido's lightweight, interactive shell configuration

# 0 ── Exit early for non‑interactive shells ──────────────────
[[ $- != *i* ]] && return

# fix locale warnings
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# 1 ── Core environment variables ─────────────────────────────
export SCRIPTS="$HOME/.local/bin/scripts"
export PERSONAL="$HOME/Documents"
export SB="$HOME/sb"
export WORK="$HOME/work"
export UNI="$HOME/uni"
export NEOVIM_DIR="$HOME/.config/nvim"
export STARTUP="$HOME/.config/autostart"
export DOTFILES="$HOME/dot"
export BLITZ="/run/media/$USER/blitz"
export EXTERNAL="/run/media/$USER/External"

# Toolchains
export GO_ROOT="/usr/local/go/bin"
export CUDA_ROOT="/usr/local/cuda-12.9"
export TRT_ROOT="/usr/local/TensorRT-10.0.0.0"
export PNPM_HOME="$HOME/.local/share/pnpm"
export BUN_INSTALL="$HOME/.bun"
export RD_HOME="$HOME/.rd/bin"

if [ -x /usr/libexec/java_home ] && /usr/libexec/java_home &>/dev/null; then
  export JAVA_HOME="$(/usr/libexec/java_home)"
elif [ -d /usr/lib64/jvm/java-23-openjdk ]; then
  export JAVA_HOME="/usr/lib64/jvm/java-23-openjdk"
fi

# 2 ── PATH ---------------------------------------------------
# Compose once; avoid duplicates
export PATH="$SCRIPTS:$GO_ROOT:$HOME/go/bin:$CUDA_ROOT/bin:$TRT_ROOT/bin:$PNPM_HOME:$BUN_INSTALL/bin:$RD_HOME:$PATH"
export LD_LIBRARY_PATH="$CUDA_ROOT/lib64:$TRT_ROOT/lib:$LD_LIBRARY_PATH"

# Rust / Cargo ------------------------------------------------
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# 3 ── Aliases & simple functions ────────────────────────────
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vi='nvim'
alias vim='nvim'
alias pn="pnpm"
alias lg="lazygit"
alias ld="lazydocker"
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
alias ip="curl https://ipinfo.io/ip; echo"
alias rcloneweb="rclone rcd --rc-web-gui"

# cd shortcuts
alias home='cd ~'
alias work='cd $WORK'
alias pers='cd $PERSONAL'
alias uni='cd $UNI'
alias sb='cd $SB'
alias nvdir='cd $NEOVIM_DIR'
alias dot='cd $DOTFILES'
alias games="cd $EXTERNAL/Games"

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

# 4 ── Lazy‑load heavy helper(s) ───────────────────────────────
# --- fnm ----------------------------------------------------
eval "$(fnm env --use-on-cd --shell bash)"

# --- tmux-sessionizer ---------------------------------------
if [[ $- == *i* ]]; then
  bind '"\C-f":"tmux-sessionizer\n"'
fi

# 5 ── Prompt & colours ──────────────────────────────────────
# Simple coloured prompt with git branch (git‑prompt loads fast)
if [ -f "/$HOME/.local/bin/lib/git-prompt.sh" ]; then
  . "/$HOME/.local/bin/lib/git-prompt.sh"
  PS1='\[\e[38;5;250m\][\u@\h \w]\[\e[0m\]$(__git_ps1 " (%s)")\$ '
else
  PS1='\[\e[38;5;250m\][\u@\h \w]\[\e[0m\]\$* '
fi

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

# Created by `pipx` on 2025-10-26 13:07:17
export PATH="$PATH:/Users/oasido/dot/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
