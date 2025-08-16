if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias cat 'bat --paging=never'
# ---- 温柔提醒使用 zoxide 的函数 ----
function cd
    # 首先，执行真正的、内置的 cd 命令，并传递所有参数
    builtin cd $argv

    # 然后，检查 cd 命令是否执行成功
    if test $status -eq 0
        # 如果成功了，就打印一个小提示
        echo -e "\e[34m💡 提示：下次可以试试用 'z' 来快速跳转哦！\e[0m"
    end
end
# ------------------------------------
zoxide init fish | source
