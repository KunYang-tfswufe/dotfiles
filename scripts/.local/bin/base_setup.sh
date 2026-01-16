#!/bin/bash

# update && upgrade
sudo apt -y update && sudo apt -y upgrade

# basic-debian
sudo apt -y install nodejs wget npm picom fzf tmux pass pass-otp oathtool stow gnupg ripgrep rclone gh mpv yt-dlp 7zip starship eza arp-scan sshfs jq ffmpeg

# fish
sudo apt -y install fish && sudo chsh -s $(which fish) $USER
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher install reitzig/sdkman-for-fish@v2.1.0

# sdkman
curl -s "https://get.sdkman.io" | bash
source "/home/free514dom/.sdkman/bin/sdkman-init.sh"
sdk install java 21.0.9-tem
sdk install gradle 9.2.1

# bat
sudo apt -y install bat
ln -s /usr/bin/batcat ~/.local/bin/bat

# repomix
sudo npm install -g repomix

# bottom
wget https://github.com/ClementTsang/bottom/releases/download/0.12.3/bottom_0.12.3-1_amd64.deb && sudo apt -y install ./bottom_0.12.3-1_amd64.deb && rm bottom_0.12.3-1_amd64.deb

# helix
wget https://github.com/helix-editor/helix/releases/download/25.07.1/helix_25.7.1-1_amd64.deb && sudo apt -y install ./helix_25.7.1-1_amd64.deb && rm helix_25.7.1-1_amd64.deb

# clipse
curl -L https://github.com/savedra1/clipse/releases/download/v1.2.0/clipse_v1.2.0_linux_x11_amd64.tar.gz > /tmp/clipse.tar.gz \
  && tar -xvf /tmp/clipse.tar.gz -C /tmp \
  && mkdir -p $HOME/.local/bin \
  && install /tmp/clipse-linux-x11-amd64 $HOME/.local/bin/clipse \
  && rm /tmp/clipse.tar.gz /tmp/clipse-linux-x11-amd64


