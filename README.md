# dot

personal dotfiles managed with GNU Stow.

## install

```bash
cd ~/dot
stow -t ~ .
stow -t ~ linux    # linux-specific scripts and binaries
```

## uninstall

```bash
cd ~/dot
stow -D -t ~ linux  # remove linux-specific first
stow -D -t ~ .      # then remove base
```

## brew

```bash
brew bundle install

# to dump brew into a Brewfile:
brew bundle dump
```

## requirements

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Homebrew](https://brew.sh/) (macOS only)
