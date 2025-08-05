# macos follows old bsd rules, so we source bashrc here as well
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# homebrew (linux)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# homebrew (mac)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
