.PHONY: stow unstow restow generate-ignore clean

# Generate ignore file and stow
stow: generate-ignore
	@stow -t ~ .

# Unstow dotfiles
unstow:
	@stow -D -t ~ .

# Restow (useful after changes)
restow: generate-ignore
	@stow -R -t ~ .

# Just generate ignore file
generate-ignore:
	@./.stow/generate-ignore.sh

# Clean generated files
clean:
	@rm -f .stow-local-ignore
