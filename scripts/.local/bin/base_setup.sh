#!/bin/bash

# update && upgrade
sudo apt -y update && sudo apt -y upgrade

# basic-debian
sudo apt -y install curl wget unzip picom fzf tmux pass pass-otp oathtool stow gnupg ripgrep rclone mpv yt-dlp 7zip starship eza arp-scan sshfs jq pandoc ffmpeg openjdk-21-jdk maven htop nodejs npm bat gh pipx

# trafilatura
pipx install trafilatura

# fish
sudo apt -y install fish && sudo chsh -s $(which fish) $USER

# repomix
command -v repomix > /dev/null || sudo npm install -g repomix

# helix
command -v hx > /dev/null || (wget https://github.com/helix-editor/helix/releases/download/25.07.1/helix_25.7.1-1_amd64.deb && sudo apt -y install ./helix_25.7.1-1_amd64.deb && rm helix_25.7.1-1_amd64.deb)
