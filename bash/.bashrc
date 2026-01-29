# .bashrc

# 1. 交互式 Shell 检查
# 如果不是交互式运行，则不执行任何操作（避免破坏 scp 或 sftp 等脚本）
[[ $- != *i* ]] && return

# 2. 历史记录配置 (History)
# 忽略重复命令和以空格开头的命令（保护隐私）
export HISTCONTROL=ignoreboth
# 追加历史记录而不是覆盖
shopt -s histappend
# 历史记录文件大小
export HISTSIZE=10000
export HISTFILESIZE=20000
# 保存所有命令的时间戳
export HISTTIMEFORMAT="%F %T "

# 3. 窗口大小调整
# 每次命令执行后检查窗口大小，确保长行自动换行正确
shopt -s checkwinsize

# 4. 颜色支持
# 检查终端是否支持颜色
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# 5. 自定义提示符 (PS1)
# 格式: [用户@主机名 当前目录]$ 
# 颜色: 用户名绿色，目录蓝色
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    # 简易彩色提示符
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

# 6. 常用别名 (Aliases)
# --- 导航 ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .3='cd ../../../'

# --- 列表显示 ---
alias ll='ls -alF'   # 显示所有文件、详细信息、文件类型后缀
alias la='ls -A'     # 显示除 . 和 .. 之外的所有文件
alias l='ls -CF'     # 紧凑列表

# --- 安全操作 (防止手滑删除重要文件) ---
alias rm='rm -i'     # 删除前询问
alias cp='cp -i'     # 覆盖前询问
alias mv='mv -i'     # 覆盖前询问

# --- 实用工具 ---
alias h='history'
alias c='clear'
alias path='echo -e ${PATH//:/\\n}' # 易读的方式显示环境变量 PATH
alias now='date +"%T"'

# 7. 实用函数 (Functions)

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 自动解压 (根据后缀名判断解压方式)
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# 8. 路径变量 (PATH)
# 将用户个人的 bin 目录加入 PATH (如果存在)
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# 9. 加载额外的配置 (可选)
# 如果你有不想上传到 git 的私有配置（如 API Key），放在 .bashrc_private 中
if [ -f ~/.bashrc_private ]; then
    . ~/.bashrc_private
fi
