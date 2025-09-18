# macos follows old bsd rules, so we source bashrc here as well
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# homebrew (mac)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# homebrew (linux)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.bash.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.bash.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.bash.inc'; fi
