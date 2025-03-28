function fvim --argument-names query --description 'Fuzzy find file and open in nvim'
    set --local filePath (fzf -q "$argv")
    if test -z $filePath
        return 1
    end

    nvim $filePath
end
