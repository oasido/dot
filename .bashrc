export ZSH="$HOME/.oh-my-zsh"
export SCRIPTS="$HOME/.local/bin/scripts"
export PERSONAL="$HOME/personal"
export SECOND_BRAIN="$HOME/sb"
export WORK="$HOME/work"
export UNI="$HOME/uni"
export NEOVIM_DIR="$HOME/.config/nvim"
export STARTUP="$HOME/.config/autostart"
export NVM_DIR="$HOME/.nvm"
export GO="/usr/local/go/bin"
export DOTFILES="$HOME/dot"
export BLITZ="/run/media/oasido/blitz"
export EXTERNAL="/run/media/oasido/External"

if [[ $- == *i* ]]; then
	bind '"\C-f":"tmux-sessionizer\n"'
fi

# ~~~~~~~~~~~~~~~ Aliases ~~~~~~~~~~~~~~~~~~~~~~~~
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias da='date "+%Y-%m-%d %A %T %Z"'
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias h="history | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias f="find . | grep "
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
alias openports="ss -tulnpe"
alias vi="nvim"
alias vim="nvim"
alias c="clear"
alias pn="pnpm"
alias rm="trash"
alias sysupdate="sudo zypper ref && sudo zypper update && sudo zypper dup"
alias lg="lazygit"
alias flatls="flatpak list --app --columns=size,name|sort -g | grep MB"
alias fpe="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' | xargs nvim"
alias fp="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"
alias getip="ip a | grep 192"
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# cd
alias work="cd $WORK"
alias pers="cd $PERSONAL"
alias uni="cd $UNI"
alias sb="cd $SECOND_BRAIN"
alias scripts="cd $SCRIPTS"
alias startup="cd $STARTUP"
alias dot="cd $DOTFILES"
alias dotc="cd $DOTFILES/.config && vi"

# ricing
alias es="vi $SCRIPTS"
alias ev="cd $HOME/.config/nvim && vi"
alias ez="vi $HOME/.zshrc"
alias eb="vi $HOME/.bashrc"
alias sz="source $HOME/.zshrc"
alias sbr="source $HOME/.bashrc"
alias heb="setxkbmap -layout us,il -option 'caps:ctrl_modifier,grp:alt_shift_toggle'"
alias games="cd $EXTERNAL/Games"
alias airplay="uxplay -p 5100"

# lynx
alias ?="duck"
alias ??="google"

if [ -f ~/.personal_aliases ]; then
	. ~/.personal_aliases
fi

if [ -f ~/.work_aliases ]; then
	. ~/.work_aliases
fi

# ~~~~~~~~~~~~~~~ Path Configuration ~~~~~~~~~~~~~~~~~~~~~~~~
export PATH="$SCRIPTS:$PATH"
export PATH="$GO:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$TURSO_PATH:$PATH"

# NVIDIA
export PATH="/usr/local/cuda-11.8/bin:$PATH"
export PATH="/usr/local/TensorRT-8.6.1.6/bin:$PATH"
export PATH="/usr/local/TensorRT-8.6.1.6/python/venv/lib/python3.11/site-packages/onnxruntime/capi:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda-11.8/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/usr/local/TensorRT-8.6.1.6/lib:$LD_LIBRARY_PATH"

# JAVA
export JAVA_HOME="/usr/lib64/jvm/java-23-openjdk"

# ~~~~~~~~~~~~~~~ NVM and Bash Completion ~~~~~~~~~~~~~~~~~~~~~~~~
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# ~~~~~~~~~~~~~~~ Editor Configuration ~~~~~~~~~~~~~~~~~~~~~~~~
export EDITOR='nvim' # preferred editor for local and remote sessions
export VISUAL='nvim'

# ~~~~~~~~~~~~~~~ Bash Shell Options  ~~~~~~~~~~~~~~~~~~~~~~~~
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=2000
shopt -s checkwinsize
shopt -s histappend
PROMPT_COMMAND='history -a'

# ~~~~~~~~~~~~~~~ Other ~~~~~~~~~~~~~~~~~~~~~~~~
# search through history with up/down arrows
bind '"\e[A": history-search-backward' 2>/dev/null
bind '"\e[B": history-search-forward' 2>/dev/null

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi
. "$HOME/.cargo/env"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	PROMPT_COMMAND='PS1_CMD1=$(__git_ps1 "(%s) ")'
	PS1='\[\e[38;5;40m\][\[\e[38;5;33m\]\u\[\e[0m\]@\[\e[38;5;250m\]\h\[\e[0m\] \W\[\e[38;5;40m\]]\[\e[0m\]\\$ \[\e[38;5;34m\]${PS1_CMD1}\[\e[0m\]'
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Color for man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# pnpm
export PNPM_HOME="/home/oasido/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# >>> b2v4 autocomplete >>>
# This section is managed by b2v4 . Manual edit may break automated updates.
source /home/oasido/.bash_completion.d/b2v4
# <<< b2v4 autocomplete <<<

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/home/oasido/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
