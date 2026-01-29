# .profile

# 设置 PATH (将用户个人的 bin 目录加入路径)
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export PATH

# 设置默认编辑器 (推荐 vim 或 nano)
export EDITOR=vim
export VISUAL=vim
