# .bash_profile

# 1. 如果 .profile 存在，加载它 (加载环境变量)
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

# 2. 如果 .bashrc 存在，加载它 (加载 Bash 专属配置)
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
