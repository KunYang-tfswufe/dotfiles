#!/bin/bash
SESSION="my-layout"
WINDOW_NAME="DevWork"

# 1. 清理旧会话
tmux kill-session -t $SESSION 2>/dev/null

# 2. 新建会话 (左侧主面板)
# -c: 指定该窗口的工作目录为 ~/dotfiles
# -d: 后台运行
tmux new-session -d -s $SESSION -n $WINDOW_NAME -c "$HOME/dotfiles"

# 3. 运行编辑器 (左侧)
# 发送 helix 命令
tmux send-keys -t $SESSION:$WINDOW_NAME 'hx .' C-m

# 4. 左右切分 (创建右侧栏)
# -h: 水平切分
# -p 30: 新切出来的面板(右侧)占 30% 宽度 -> 意味着左侧保留 70%
# -c "$HOME/dotfiles": 这里也设为 dotfiles 目录，方便你在右侧直接使用 git
tmux split-window -h -t $SESSION:$WINDOW_NAME -p 30 -c "$HOME/dotfiles"

# 5. 右侧保持空闲
# (原脚本的 split-window -v 和 send-keys btm 已删除)
# 此时右侧就是一个完整的空闲终端，可以直接输入命令

# 6. 最后光标回到左侧主工作区 (可选)
# 如果你希望启动后光标直接在编辑器里，保留下面这行
# 如果你希望启动后光标在右侧准备输入 git 命令，注释掉下面这行
tmux select-pane -L -t $SESSION:$WINDOW_NAME

# 7. 进入会话
tmux attach -t $SESSION
