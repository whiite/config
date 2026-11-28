# Sets up rex specific command overlays for lazygit
if set -q REX_BLOCK
    set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/rex.yml"
end
