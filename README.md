# dot

## quick start

```bash
# install dotfiles
make stow

# remove dotfiles
make unstow

# refresh after making changes
make restow
```

## what it does

- automatically detects your OS (macOS/Linux) and uses the right ignore patterns
- creates symlinks from this repo to your home directory
- keeps OS-specific files pretty organized

## requirements

- [GNU Stow](https://www.gnu.org/software/stow/)
  - macOS: `brew install stow`
  - Linux: `bro...`
