#! fish
function ssh --description "Wrapper around SSH to use the SSH kitten if available"
    if is_kitty
        kitten ssh $argv
    else
        command ssh $argv
    end
end
