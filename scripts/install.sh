#!/bin/sh

log() {
	echo "RMI PACKER: $@"
}

set -ex

log "Running install script"

log "Creating filesystems"
mkfs.ext4 -L boot /dev/sda1
zpool create -O xattr=sa -O acltype=posixacl -O mountpoint=none -R /mnt rpool /dev/sda2
zfs create -o mountpoint=none rpool/root
zfs create -o mountpoint=legacy rpool/root/nixos
zfs create -o mountpoint=legacy -o com.sun:auto-snapshot=true rpool/home

log "Mounting filesystems"
mount -t zfs rpool/root/nixos /mnt
mkdir -p /mnt/boot /mnt/home
mount -t zfs rpool/home /mnt/home
mount LABEL=boot /mnt/boot

log "Generating config"
nixos-generate-config --root /mnt
curl $PACKER_HTTP_ADDR/configuration.nix > /mnt/etc/nixos/configuration.nix
curl $PACKER_HTTP_ADDR/boot.png > /mnt/etc/nixos/boot.png
sed -i 's/%adminUsername%/'"$ADMIN_USERNAME"'/g' /mnt/etc/nixos/configuration.nix
sed -i 's/%adminPassword%/'"$ADMIN_PASSWORD"'/g' /mnt/etc/nixos/configuration.nix

log "Nix install"
nixos-install

log "Creating Desktop shortcuts"
mkdir -p /mnt/home/rmi/Desktop
cat > /mnt/home/rmi/Desktop/contest.desktop <<EOF
[Desktop Entry]

Type=Link
Version=1.0

Name=Contest Site
Comment=Open the contest platform in the browser
URL=http://cms.lbi.ro:8888
Icon=/etc/nixos/boot.png
EOF
cat > /mnt/home/rmi/Desktop/README.txt <<EOF
<placeholder information>

The time displayed is in UTC.

You can change the keyboard layout from the settings.

For users of Code::Blocks: you must select the GCC compiler with a
mouse click when you start the program for the first time and click the "Make default" button.
EOF
chmod 555 /mnt/home/rmi/Desktop/contest.desktop
chmod 444 /mnt/home/rmi/Desktop/README.txt
chown -R 1001 /mnt/home/rmi
