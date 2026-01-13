#!/bin/bash

# update
sudo apt -y update && sudo apt -y upgrade

# github-cli
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env.fish"

# eza
cargo install eza

# starship
sudo apt install starship

# basic-fedora
sudo dnf -y install wl-clipboard wf-recorder grim slurp jq dunst fzf stow ripgrep oathtool pass pass-otp gnupg

# basic-commands
sudo apt -y install fzf stow ripgrep gnupg pass pass-otp oathtool mpv bat

# bottom
cargo install bottom --locked

# bat
sudo apt -y install bat
ln -s /usr/bin/batcat ~/.local/bin/bat
