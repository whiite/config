#! fish
function ssh --description "Wrapper around SSH to use the SSH kitten if available"
    if type -q kitten
        kitten ssh $argv
    else
        command ssh $argv
    end
end
