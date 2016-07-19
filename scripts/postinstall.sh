#!/bin/sh

set -e

USER=kiba
UHOME=/home/$USER

# Setup my configuration lib
sudo -u $USER mkdir -p $UHOME/lib
sudo -u $USER git clone https://github.com/KibaFox/nixos.git $UHOME/lib/nixos
sudo -u $USER git -C $UHOME/lib/nixos remote set-url --push origin git@github.com:KibaFox/nixos.git
sudo -u $USER git clone https://github.com/KibaFox/dotfiles.git $UHOME/lib/dotfiles
sudo -u $USER git -C $UHOME/lib/dotfiles remote set-url --push origin git@github.com:KibaFox/dotfiles.git

# Install nixos configuration
mv /etc/nixos/configuration.nix /etc/nixos/bak.nix
ln -s $UHOME/lib/nixos/machines/vbox.nix /etc/nixos/configuration.nix
nixos-rebuild switch --upgrade

# Cleanup any previous generations and delete old packages
nix-collect-garbage -d

# I haven't been able to get this part to work.
# Install dotfiles
#sudo -i -u $USER $UHOME/lib/dotfiles/install
