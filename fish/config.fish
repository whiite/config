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

    # `atuin init fish` binds `?` only in the default keymap not vi mode
    bind --mode insert "?" _atuin_ai_question_mark
end

set fish_cursor_insert block blink
set fish_function_path (path resolve $__fish_config_dir/functions/*/) $fish_function_path

# Shell integrations (optional: only initialise when the tool is installed)
command -sq zoxide; and zoxide init fish | source
command -sq fzf; and fzf --fish | source
command -sq direnv; and direnv hook fish | source
command -sq atuin; and atuin init fish | source

