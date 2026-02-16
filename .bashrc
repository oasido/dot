# oasido's .bashrc

[[ $- != *i* ]] && return

# fix locale warnings
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# === environment variables
export SCRIPTS="$HOME/.local/bin/scripts"
export PERSONAL="$HOME/Documents"
export SB="$HOME/sb"
export WORK="$HOME/work"
export UNI="$HOME/uni"
export NEOVIM_DIR="$HOME/.config/nvim"
export STARTUP="$HOME/.config/autostart"
export DOTFILES="$HOME/dot"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export BLITZ="/run/media/$USER/blitz"
  export EXTERNAL="/run/media/$USER/External"
fi

# toolchains
export PNPM_HOME="$HOME/.local/share/pnpm"
export BUN_INSTALL="$HOME/.bun"

export GO_ROOT="/usr/local/go/bin"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export CUDA_ROOT="/usr/local/cuda-12.9"
  export TRT_ROOT="/usr/local/TensorRT-10.0.0.0"
fi

# java
if [ -d /opt/homebrew/opt/java ]; then
  export JAVA_HOME="/opt/homebrew/opt/java"
elif [ -d /usr/lib64/jvm/java-23-openjdk ]; then
  export JAVA_HOME="/usr/lib64/jvm/java-23-openjdk"
fi

# === path
PATH_ADDITIONS=""
[ -d "$SCRIPTS" ] && PATH_ADDITIONS="$PATH_ADDITIONS:$SCRIPTS"
[ -d "$GO_ROOT" ] && PATH_ADDITIONS="$PATH_ADDITIONS:$GO_ROOT"
[ -d "$HOME/go/bin" ] && PATH_ADDITIONS="$PATH_ADDITIONS:$HOME/go/bin"
[ -d "$PNPM_HOME" ] && PATH_ADDITIONS="$PATH_ADDITIONS:$PNPM_HOME"
[ -d "$BUN_INSTALL/bin" ] && PATH_ADDITIONS="$PATH_ADDITIONS:$BUN_INSTALL/bin"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  [ -d "$CUDA_ROOT/bin" ] && PATH_ADDITIONS="$PATH_ADDITIONS:$CUDA_ROOT/bin"
  [ -d "$TRT_ROOT/bin" ] && PATH_ADDITIONS="$PATH_ADDITIONS:$TRT_ROOT/bin"
fi

export PATH="$PATH_ADDITIONS:$PATH"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  LD_LIBRARY_ADDITIONS=""
  [ -d "$CUDA_ROOT/lib64" ] && LD_LIBRARY_ADDITIONS="$CUDA_ROOT/lib64:$LD_LIBRARY_ADDITIONS"
  [ -d "$TRT_ROOT/lib" ] && LD_LIBRARY_ADDITIONS="$LD_LIBRARY_ADDITIONS:$TRT_ROOT/lib"
  [ -n "$LD_LIBRARY_ADDITIONS" ] && export LD_LIBRARY_PATH="$LD_LIBRARY_ADDITIONS:$LD_LIBRARY_PATH"
fi

## rust/cargo
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# === aliases and funcs
# editor aliases
alias vi='nvim'
alias vim='nvim'

# ls with eza
alias ls='eza'
alias l='ls -CF'
alias ll='eza -la --git'
alias la='eza -a'
alias lt='eza --tree --level=2'
alias tree='eza --tree'

alias pn="pnpm"
alias lg="lazygit"
alias ld="lazydocker"

# utilities
alias c='clear'
alias h="history | grep "
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
alias ff="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"
alias fpe="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' | xargs nvim"
alias tb="nc termbin.com 9999"
alias ip="curl https://ipinfo.io/ip; echo"
alias rcloneweb="rclone rcd --rc-web-gui"

## linux-specific
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  alias openports="ss -tulnpe"
  alias flatls="flatpak list --app --columns=size,name|sort -g | grep MB"
  alias airplay="uxplay -p 5100"
  alias games="cd $EXTERNAL/Games"
fi

# cd shortcuts
alias work='cd $WORK'
alias pers='cd $PERSONAL'
alias uni='cd $UNI'
alias sb='cd $SB'
alias nvdir='cd $NEOVIM_DIR'
alias dot='cd $DOTFILES'

# uni / c helpers
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

# === lazy-loaded tools
## fnm
eval "$(fnm env --use-on-cd --shell bash)"

## fzf
export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border --inline-info --color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7"
# exclude .git dir and use fd if available
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

## zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

## tmux-sessionizer
if [[ $- == *i* ]]; then
  bind '"\C-f":"tmux-sessionizer\n"'
fi

# === prompt
# Simple colored prompt with git branch (git‑prompt loads fast)
if [ -f "$HOME/.local/bin/lib/git-prompt.sh" ]; then
  . "$HOME/.local/bin/lib/git-prompt.sh"
  PS1='\[\e[38;5;250m\][\u@\h \w]\[\e[0m\]$(__git_ps1 " (%s)")\$ '
else
  PS1='\[\e[38;5;250m\][\u@\h \w]\[\e[0m\]\$ '
fi

# === editor and history
export EDITOR='nvim'
export VISUAL='nvim'
export MAN_POSIXLY_CORRECT=1

# history configuration
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
shopt -s checkwinsize

# === funcs
sysupdate() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # linux (openSUSE zypper)
    sudo env ZYPP_CURL2=1 zypper ref &&
      sudo zypper update &&
      sudo env ZYPP_PCK_PRELOAD=1 zypper dup
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew update && brew upgrade && brew cleanup
  else
    echo "unsupported OS: $OSTYPE"
    return 1
  fi
  command -v tldr &>/dev/null && tldr --update
}

compress_video() {
  # check if input file exists
  if [[ ! -f "$1" ]]; then
    echo "error: file '$1' not found"
    return 1
  fi

  # get input filename without extension
  local input="$1"
  local basename="${input%.*}"
  local output="${basename}_compressed.mp4"

  # detect os and set encoder accordingly
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macos - use videotoolbox hardware encoder
    # hevc_videotoolbox is h265 with gpu acceleration
    # q:v controls quality - lower is better (51-100 range)
    ffmpeg -i "$input" -vcodec hevc_videotoolbox -q:v 50 -tag:v hvc1 "$output"
  else
    # linux/other - use software encoder
    # libx265 is cpu-based but widely compatible
    # crf 28 is your original quality setting
    ffmpeg -i "$input" -vcodec libx265 -crf 28 "$output"
  fi

  echo "compressed: $output"
}

# colored GCC output
export GCC_COLORS='error=01;31:warning=01;35:note=01;36'

# Created by `pipx` on 2025-10-26 13:07:17
export PATH="$PATH:/Users/oasido/dot/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
