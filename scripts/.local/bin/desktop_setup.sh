#!/bin/bash

# update && upgrade
sudo apt -y update && sudo apt -y upgrade

sudo apt -y install alacritty copyq dunst xclip maim i3-wm i3status i3lock

sudo wget https://prism-launcher-for-debian.github.io/repo/prismlauncher.gpg -O /usr/share/keyrings/prismlauncher-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/prismlauncher-archive-keyring.gpg] https://prism-launcher-for-debian.github.io/repo $(. /etc/os-release; echo "${UBUNTU_CODENAME:-${DEBIAN_CODENAME:-${VERSION_CODENAME}}}") main" | sudo tee /etc/apt/sources.list.d/prismlauncher.list \
  && sudo apt update \
  && sudo apt install prismlauncher

# broadcom # Restart Required
sudo sed -i 's/ main / main contrib non-free /g' /etc/apt/sources.list
sudo apt update && lspci -nn | grep -q "Broadcom" && {
    sudo apt install -y linux-headers-amd64 broadcom-sta-dkms
    sudo modprobe -r b43 b44 b43legacy ssb brcmsmac bcma 2>/dev/null
    sudo modprobe wl
    echo "MBA 2015 网卡驱动已就绪！"
} || echo "未检测到 Broadcom 硬件，跳过驱动安装。"

# rpi-imager
command -v rpi-imager > /dev/null || { wget https://github.com/raspberrypi/rpi-imager/releases/download/v2.0.3/rpi-imager_2.0.3_amd64.deb && sudo apt -y install ./rpi-imager_2.0.3_amd64.deb && rm rpi-imager_2.0.3_amd64.deb; }

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

# zen
 command -v zen > /dev/null || curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh | sh
