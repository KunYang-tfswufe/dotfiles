#!/bin/bash
SESSION="my-layout"
WINDOW_NAME="DevWork"

# 1. 清理旧会话
tmux kill-session -t $SESSION 2>/dev/null

# 2. 新建会话 (左侧主面板)
# -c: 指定该窗口的工作目录为 ~/dotfiles
# -d: 后台运行，不立即进入
tmux new-session -d -s $SESSION -n $WINDOW_NAME -c "$HOME/dotfiles"

# 3. 运行编辑器 (左侧)
# 此时只有一个面板，直接发送命令
tmux send-keys -t $SESSION:$WINDOW_NAME 'hx .' C-m

# 4. 左右切分 (创建右侧栏)
# -h: 水平切分
# -p 20: 新切出来的面板(右侧)占 20% 宽度 -> 左侧保留 80%
# -c "$HOME": 右侧工具栏通常不需要在 dotfiles 目录，重置回 HOME (根据喜好可删去此参数)
tmux split-window -h -t $SESSION:$WINDOW_NAME -p 20 -c "$HOME"

# 5. 右侧上下切分
# 此时焦点自动在刚才切出来的右侧面板上
# -v: 垂直切分
# -p 30: 新切出来的面板(右下)占 30% 高度 -> 右上保留 70% (稍高)
tmux split-window -v -t $SESSION:$WINDOW_NAME -p 30 -c "$HOME"

# 6. 运行 btm (右上)
# 刚才切分完，焦点在"右下"。我们需要先选到"右上"。
tmux select-pane -U -t $SESSION:$WINDOW_NAME
tmux send-keys -t $SESSION:$WINDOW_NAME 'btm' C-m

# 7. 右下角留空
# (不需要发送任何按键命令，只需保留 Shell 即可)

# 8. 最后光标回到左侧主工作区
tmux select-pane -L -t $SESSION:$WINDOW_NAME

# 9. 进入会话
tmux attach -t $SESSION
