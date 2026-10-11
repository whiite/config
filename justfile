# Restow this repo's configs into ~/.config (the default action)
stow:
    @mkdir -p "$HOME/.config"
    @stow --verbose --restow --dir "{{justfile_dir()}}" --target "$HOME/.config" .

# Remove the symlinks this repo manages from ~/.config
unstow:
    @stow --verbose --delete --dir "{{justfile_dir()}}" --target "$HOME/.config" .
