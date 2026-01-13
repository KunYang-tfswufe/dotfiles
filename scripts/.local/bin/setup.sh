#!/bin/bash

# update && upgrade
sudo apt -y update && sudo apt -y upgrade

# basic-debian
sudo apt -y install nodejs npm hx fzf pass pass-otp oathtool stow gnupg ripgrep rclone gh mpv yt-dlp 7zip starship eza arp-scan sshfs jq dunst xclip ffmpeg maim kitty dmenu i3-wm i3status i3lock

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

# rpi-imager
wget https://github.com/raspberrypi/rpi-imager/releases/download/v2.0.3/rpi-imager_2.0.3_amd64.deb && sudo apt -y install ./rpi-imager_2.0.3_amd64.deb && rm rpi-imager_2.0.3_amd64.deb

# repomix
sudo npm install -g repomix

# bottom
wget https://github.com/ClementTsang/bottom/releases/download/0.12.3/bottom_0.12.3-1_amd64.deb && sudo apt -y install ./bottom_0.12.3-1_amd64.deb && rm bottom_0.12.3-1_amd64.deb


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

# fcitx5 # Restart Required
sudo apt install fcitx5 fcitx5-chinese-addons fcitx5-frontend-gtk3 fcitx5-frontend-qt5 im-config
im-config -n fcitx5
printf "\nexport GTK_IM_MODULE=fcitx\nexport QT_IM_MODULE=fcitx\nexport XMODIFIERS=@im=fcitx\n" >> ~/.xprofile

# v2rayA
wget -qO - https://apt.v2raya.org/key/public-key.asc | sudo tee /etc/apt/keyrings/v2raya.asc
echo "deb [signed-by=/etc/apt/keyrings/v2raya.asc] https://apt.v2raya.org/ v2raya main" | sudo tee /etc/apt/sources.list.d/v2raya.list
sudo apt update
sudo apt install v2raya v2ray ## you can install xray package instead of if you want
sudo systemctl enable --now v2raya

# daed
wget -P /tmp https://github.com/daeuniverse/daed/releases/latest/download/installer-daed-linux-$(arch).deb
sudo dpkg -i /tmp/installer-daed-linux-$(arch).deb
sudo systemctl enable --now daed

# fish
sudo apt -y install fish && sudo chsh -s $(which fish) $USER
