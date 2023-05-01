#! fish
function ghub --description "Change directory into any local GitHub folder with given virtualenv if available"
    if [ -e $HOME/GitHub/$argv[1]/.env/$argv[1]/bin/activate.fish ]; and count $argv >/dev/null
        source $HOME/GitHub/$argv[1]/.env/$argv[1]/bin/activate.fish
    else if type -q deactivate
        deactivate
    end

    if count $argv >/dev/null
        cd $HOME/GitHub/$argv[1]
    else
        cd $HOME/GitHub
    end
end
