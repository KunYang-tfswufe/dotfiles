#!/bin/bash

# update && upgrade
sudo apt -y update && sudo apt -y upgrade

# basic-debian
sudo apt -y install nodejs npm hx fzf pass pass-otp oathtool stow gnupg ripgrep rclone gh mpv yt-dlp 7zip starship eza arp-scan sshfs

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"

# broadcom # Restart Required
sudo sed -i 's/ main / main contrib non-free /g' /etc/apt/sources.list
sudo apt update && lspci -nn | grep -q "Broadcom" && {
    sudo apt install -y linux-headers-amd64 broadcom-sta-dkms
    sudo modprobe -r b43 b44 b43legacy ssb brcmsmac bcma 2>/dev/null
    sudo modprobe wl
    echo "MBA 2015 网卡驱动已就绪！"
} || echo "未检测到 Broadcom 硬件，跳过驱动安装。"

# prismlauncher
sudo wget https://prism-launcher-for-debian.github.io/repo/prismlauncher.gpg -O /usr/share/keyrings/prismlauncher-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/prismlauncher-archive-keyring.gpg] https://prism-launcher-for-debian.github.io/repo $(. /etc/os-release; echo "${UBUNTU_CODENAME:-${DEBIAN_CODENAME:-${VERSION_CODENAME}}}") main" | sudo tee /etc/apt/sources.list.d/prismlauncher.list \
  && sudo apt update \
  && sudo apt install prismlauncher

# bat
sudo apt -y install bat
ln -s /usr/bin/batcat ~/.local/bin/bat

# fish
sudo apt -y install fish && chsh -s $(which fish)

# rpi-imager
wget https://github.com/raspberrypi/rpi-imager/releases/download/v2.0.3/rpi-imager_2.0.3_amd64.deb && sudo apt -y install ./rpi-imager_2.0.3_amd64.deb && rm rpi-imager_2.0.3_amd64.deb

# repomix
sudo npm install -g repomix

# bottom
cargo install bottom --locked

# qemu
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
sudo adduser $USER libvirt
sudo adduser $USER kvm

# vagrant
sudo apt -y install vagrant
mkdir -p ~/vagrant-alpine
cd ~/vagrant-alpine
if [ ! -f Vagrantfile ]; then
    vagrant init generic/alpine318
fi
if ! vagrant plugin list | grep -q "vagrant-libvirt"; then
    vagrant plugin install vagrant-libvirt
fi

# clipse
curl -L https://github.com/savedra1/clipse/releases/download/v1.2.0/clipse_v1.2.0_linux_x11_amd64.tar.gz > /tmp/clipse.tar.gz \
  && tar -xvf /tmp/clipse.tar.gz -C /tmp \
  && mkdir -p $HOME/.local/bin \
  && install /tmp/clipse-linux-x11-amd64 $HOME/.local/bin/clipse \
  && rm /tmp/clipse.tar.gz /tmp/clipse-linux-x11-amd64











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

# daed
sudo dnf -y copr enable zhullyb/v2rayA
sudo dnf -y install daed
sudo systemctl enable --now daed

# v2rayA
sudo dnf -y copr enable zhullyb/v2rayA
sudo dnf -y install v2ray v2raya
sudo systemctl enable --now v2raya
