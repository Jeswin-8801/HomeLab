#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

USER_HOME_DIR="/home/$(who am i | awk '{print $1}')"
DOWNLOADS_DIR="$USER_HOME_DIR/Downloads"

# Fish
cp fish/config.fish "$USER_HOME_DIR"/.config/fish/config.fish

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
wget -q -P "$DOWNLOADS_DIR" "https://github.com/neovim/neovim/releases/download/${neovim_VERSION}/nvim-linux-x86_64.tar.gz"
tar -xzf "$DOWNLOADS_DIR/nvim-linux-x86_64.tar.gz" -C /opt
cd /opt/nvim-linux-x86_64
ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
cp /opt/nvim-linux-x86_64/share/man/man1/nvim.1 /usr/share/man/man1
mandb
cd -

# neovim config
cp -rf nvim "$USER_HOME_DIR"/.config/

# lnav
echo "Installing lnav..."
wget -q -P "$DOWNLOADS_DIR" "https://github.com/tstack/lnav/releases/download/v${lnav_VERSION}/lnav-${lnav_VERSION}-linux-musl-x86_64.zip"
unzip "$DOWNLOADS_DIR/lnav-${lnav_VERSION}-linux-musl-x86_64.zip" -d /opt
ln -s /opt/lnav-${lnav_VERSION}/lnav /usr/local/bin/lnav

# Oh My Posh
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin

# Superfile
echo "Installing spf..."
wget -q -P "$DOWNLOADS_DIR" "https://github.com/yorukot/superfile/releases/download/${superfile_VERSION}/superfile-linux-${superfile_VERSION}-amd64.tar.gz"
tar --strip-components=2 -xzf "$DOWNLOADS_DIR/superfile-linux-${superfile_VERSION}-amd64.tar.gz" -C /opt
ln -s /opt/superfile-linux-${superfile_VERSION}-amd64/spf /usr/local/bin/spf

# Lazygit
echo "Installing lazygit..."
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
wget -q -P "$DOWNLOADS_DIR" "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xzf "$DOWNLOADS_DIR/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" -C /opt
ln -s /opt/lazygit /usr/local/bin/lazygit

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env.fish"

# Rust CLI Tools
cargo install zoxide

# Remove unwanted files in the /opt folder
rm -f /opt/*.md /opt/LICENSE

# Install GRUB Theme
git clone https://github.com/vinceliuice/Elegant-grub2-themes.git "$DOWNLOADS_DIR/Elegant-grub2-themes"
cd "$DOWNLOADS_DIR/Elegant-grub2-themes"
./install.sh -t mojave -p float
