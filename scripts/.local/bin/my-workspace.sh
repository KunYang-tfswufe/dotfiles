#!/bin/bash
SESSION="my-layout"
WINDOW_NAME="DevWork" # 给窗口起个独特的名字

# 1. 确保清理旧的同名会话 (避免干扰)
tmux kill-session -t $SESSION 2>/dev/null

# 2. 新建会话，并明确指定窗口名称 (-n)
# 注意：这里不依赖它是 0 还是 1，我们只认名字
tmux new-session -d -s $SESSION -n $WINDOW_NAME

# 3. 左右切分 (75% 宽度)
# 关键点：-t 使用 "会话名:窗口名" 的格式
tmux split-window -h -p 25 -t $SESSION:$WINDOW_NAME

# 4. 右侧上下切分
# 这里的 target 稍微复杂点，但通常新切出来的面板是当前焦点
# 为了保险，我们先选中右边面板，再切分
tmux select-pane -t $SESSION:$WINDOW_NAME.1 2>/dev/null || tmux select-pane -t $SESSION:$WINDOW_NAME.0
tmux split-window -v -l 10

# 5. 发送命令 (根据面板布局位置)
# 面板编号是自动生成的，通常主窗口是 .0 (或 .1)，新切出来的是后续编号
# 既然布局已经定好，我们可以用 "方向" 来选择面板，这样更直观！

# 选择最左边的大面板 -> 运行 Vim
tmux select-pane -L -t $SESSION:$WINDOW_NAME
tmux send-keys 'vim' C-m

# 选择右下角面板 -> 运行 Log
tmux select-pane -R -t $SESSION:$WINDOW_NAME
tmux select-pane -D -t $SESSION:$WINDOW_NAME
tmux send-keys 'tail -f /var/log/system.log' C-m

# 选择右上角面板 -> 运行 htop
tmux select-pane -U -t $SESSION:$WINDOW_NAME
tmux send-keys 'htop' C-m

# 6. 最后光标回到左侧主工作区
tmux select-pane -L -t $SESSION:$WINDOW_NAME

# 7. 进入会话
tmux attach -t $SESSION
