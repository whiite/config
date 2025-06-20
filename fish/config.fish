# Vi mode config
function fish_user_key_bindings
    # Execute this once per mode that emacs bindings should be used in
    fish_default_key_bindings -M insert
    fish_default_key_bindings -M default

    # Then execute the vi-bindings so they take precedence when there's a conflict.
    # Without --no-erase fish_vi_key_bindings will default to
    # resetting all bindings.
    # The argument specifies the initial mode (insert, "default" or visual).
    fish_vi_key_bindings --no-erase insert
    bind --mode insert ctrl-n down-or-search # Use default binding 
    bind --mode default ctrl-n down-or-search
end
set fish_cursor_insert block blink

zoxide init fish | source
fzf --fish | source
era completion fish | source
