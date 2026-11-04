function ls --wraps='eza --icons always' --description 'alias ls=eza --icons always'
    # eza reads a file list from stdin when no path is given and stdin is not
    # a tty; pass "." so non-interactive callers (bang commands, scripts)
    # list the working directory instead of reading empty stdin.
    if not isatty stdin
        set -p argv .
    end
    eza --icons always $argv
end
