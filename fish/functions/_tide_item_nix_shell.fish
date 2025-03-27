function _tide_item_nix_shell
    if test -n "$IN_NIX_SHELL" || echo "$PATH" | grep -qc /nix/store/
        _tide_print_item nix_shell "nix shell $tide_nix_shell_icon "
    end
end
