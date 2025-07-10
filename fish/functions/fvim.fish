function fvim --argument-names query --description 'Fuzzy find file and open in nvim'
    set -lx FZF_DEFAULT_COMMAND 'rg --files --hidden'
    set --local filePath (fzf -q "$argv" -1 )
    if test -z $filePath
        return 1
    end

    nvim $filePath
end
