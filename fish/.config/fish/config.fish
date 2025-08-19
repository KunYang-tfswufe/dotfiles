if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias cat 'bat --paging=never'
# ---- A function to gently remind about using zoxide ----
function cd
    # First, execute the real, built-in cd command with all arguments
    builtin cd $argv

    # Then, check if the cd command was successful
    if test $status -eq 0
        # If successful, print a small tip
        echo -e "\e[34mTip: Next time, try using 'z' for a faster jump!\e[0m"
    end
end
# ------------------------------------
zoxide init fish | source
set -gx VISUAL nvim
