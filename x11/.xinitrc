#!/bin/sh

# 1. 加载 X 资源
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

# 2. 加载环境变量 (输入法等)
[ -f ~/.xprofile ] && . ~/.xprofile

# 3. 启动 i3 (带 dbus 支持)
exec dbus-launch --exit-with-session i3
