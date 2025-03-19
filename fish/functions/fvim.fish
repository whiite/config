function fvim --argument-names query --description 'Fuzzy find file and open in nvim'
    set --local filePath (fzf -q "$query")
    if test -z $filePath
        return 1
    end

    nvim $filePath
end
