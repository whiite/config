#! fish
function srcd --description "Change directory to any subdirectory of ~/src"
    if count $argv >/dev/null
        cd $HOME/src/$argv[1]
    else
        cd $HOME/src
    end
end
