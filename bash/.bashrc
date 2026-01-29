# .bashrc

# 1. 如果不是交互式终端，直接退出 (避免干扰脚本运行)
[[ $- != *i* ]] && return

# 2. 历史记录设置
HISTSIZE=10000                  # 内存中保留的历史条数
HISTFILESIZE=20000              # 历史文件中保留的条数
HISTCONTROL=ignoreboth:erasedups # 忽略重复命令和以空格开头的命令
shopt -s histappend             # 追加历史而不是覆盖

# 3. 窗口大小自适应
shopt -s checkwinsize

# 4. 颜色设置 (开启 ls 和 grep 的颜色)
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# 5. 常用别名 (Alias)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# 6. 命令提示符 (PS1) - 这是一个经典的绿色高亮提示符
# 格式: [用户名@主机名 当前目录]$ 
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt
