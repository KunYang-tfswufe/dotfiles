#!/bin/bash

# update && upgrade
sudo apt -y update && sudo apt -y upgrade

# basic-debian
sudo apt -y install nodejs npm hx fzf pass pass-otp oathtool stow gnupg ripgrep rclone gh mpv yt-dlp 7zip starship eza arp-scan

# prismlauncher
sudo wget https://prism-launcher-for-debian.github.io/repo/prismlauncher.gpg -O /usr/share/keyrings/prismlauncher-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/prismlauncher-archive-keyring.gpg] https://prism-launcher-for-debian.github.io/repo $(. /etc/os-release; echo "${UBUNTU_CODENAME:-${DEBIAN_CODENAME:-${VERSION_CODENAME}}}") main" | sudo tee /etc/apt/sources.list.d/prismlauncher.list \
  && sudo apt update \
  && sudo apt install prismlauncher

# fish
sudo apt -y install fish && chsh -s $(which fish)

# rpi-imager
wget https://github.com/raspberrypi/rpi-imager/releases/download/v2.0.3/rpi-imager_2.0.3_amd64.deb && sudo apt -y install ./rpi-imager_2.0.3_amd64.deb && rm rpi-imager_2.0.3_amd64.deb

# repomix
sudo npm install -g repomix













# broadcom-wl # Restart Required
sudo dnf -y install broadcom-wl

# close firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# close sddm
sudo systemctl disable sddm

# basic
sudo dnf -y install wl-clipboard wf-recorder grim slurp jq dunst

# fcitx5 # Restart Required
sudo dnf -y install fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-chinese-addons fcitx5-rime
mkdir -p ~/.config/environment.d
echo "GTK_IM_MODULE=fcitx" > ~/.config/environment.d/im.conf
echo "QT_IM_MODULE=fcitx" >> ~/.config/environment.d/im.conf
echo "XMODIFIERS=@im=fcitx" >> ~/.config/environment.d/im.conf
echo "SDL_IM_MODULE=fcitx" >> ~/.config/environment.d/im.conf
echo "GLFW_IM_MODULE=ibus" >> ~/.config/environment.d/im.conf

# qemu
sudo dnf -y install @virtualization

# bat
sudo dnf -y install bat

# bottom
sudo dnf -y copr enable atim/bottom && sudo dnf -y install bottom

# daed
sudo dnf -y copr enable zhullyb/v2rayA
sudo dnf -y install daed
sudo systemctl enable --now daed

# v2rayA
sudo dnf -y copr enable zhullyb/v2rayA
sudo dnf -y install v2ray v2raya
sudo systemctl enable --now v2raya

# clipse
sudo dnf -y copr enable azandure/clipse && sudo dnf -y install clipse

# sshfs
sudo dnf -y install sshfs

# vagrant
wget -O- https://rpm.releases.hashicorp.com/fedora/hashicorp.repo | sudo tee /etc/yum.repos.d/hashicorp.repo
sudo yum list available | grep hashicorp
sudo dnf -y install vagrant libvirt-devel
mkdir ~/vagrant-alpine
cd vagrant-alpine
vagrant init generic/alpine318
vagrant plugin install vagrant-libvirt

