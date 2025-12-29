#!/bin/bash

sudo dnf remove neovim
# 如果安装了 python 客户端，建议一并卸载
sudo dnf remove python3-neovim

rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
rm -rf ~/.config/coc
