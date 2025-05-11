#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

USER_HOME_DIR="/home/$(who am i | awk '{print $1}')"

# Fish
cp fish/config.fish ~/.config/fish/config.fish

apt update
apt -y upgrade

apt install -y btop bat lsd neofetch fd-find fzf duf ripgrep unzip
apt install -y build-essential

# VERSIONS
neovim_VERSION="v0.11.1"
lnav_VERSION="0.12.4"
superfile_VERSION="v1.2.1"

# neovim
echo "Installing neovim..."
wget -q -P ~/Downloads "https://github.com/neovim/neovim/releases/download/${neovim_VERSION}/nvim-linux-x86_64.tar.gz"
tar -xzf ~/Downloads/nvim-linux-x86_64.tar.gz -C /opt
cd /opt/nvim-linux-x86_64
ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
cp /opt/nvim-linux-x86_64/share/man/man1/nvim.1 /usr/share/man/man1
mandb

# lnav
echo "Installing lnav..."
wget -q -P ~/Downloads "https://github.com/tstack/lnav/releases/download/v${lnav_VERSION}/lnav-${lnav_VERSION}-linux-musl-x86_64.zip"
unzip ~/Downloads/lnav-${lnav_VERSION}-linux-musl-x86_64.zip -d /opt
ln -s /opt/${lnav_VERSION}/lnav /usr/local/bin/lnav

# Superfile
echo "Installing spf..."
wget -q -P ~/Downloads "https://github.com/yorukot/superfile/releases/download/${superfile_VERSION}/superfile-linux-${superfile_VERSION}-amd64.tar.gz"
tar xf ~/Downloads/superfile-linux-${superfile_VERSION}-amd64.tar.gz -C /opt
ln -s /opt/dist/superfile-linux-${superfile_VERSION}-amd64/spf /usr/local/bin/spf

# Oh My Posh
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$USER_HOME_DIR/.cargo/env"

# Rust CLI Tools
cargo install zoxide
