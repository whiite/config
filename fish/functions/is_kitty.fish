function is_kitty --description "Checks if the current shell is running inside of the kitty terminal"
    if set -q KITTY_WINDOW_ID; or test "$TERM" = xterm-kitty
        return 0
    else
        return 1
    end
end
