#!/usr/bin/env nix-shell
#! nix-shell -i bash -p mkpasswd

log() {
	echo "RMI PACKER: $@"
}

set -ex

log "Running install script"

log "Creating filesystems"
mkfs.ext4 -L boot /dev/sda1
mkswap -L swap /dev/sda2
zpool create -O xattr=sa -O acltype=posixacl -O mountpoint=none -R /mnt rpool /dev/sda3
zfs create -o mountpoint=none rpool/root
zfs create -o mountpoint=legacy rpool/root/nixos
zfs create -o mountpoint=legacy -o com.sun:auto-snapshot=true rpool/home

log "Mounting filesystems"
mount -t zfs rpool/root/nixos /mnt
mkdir -p /mnt/boot /mnt/home
mount -t zfs rpool/home /mnt/home
mount LABEL=boot /mnt/boot
swapon -L swap

log "Generating config"
nixos-generate-config --root /mnt
curl $PACKER_HTTP_ADDR/configuration.nix > /mnt/etc/nixos/configuration.nix
curl $PACKER_HTTP_ADDR/boot.png > /mnt/etc/nixos/boot.png

# hash password
ADMIN_PASSWORD="$(echo "$ADMIN_PASSWORD" | mkpasswd -s -m sha-512)"

sed -i 's:%adminUsername%:'"$ADMIN_USERNAME"':g' /mnt/etc/nixos/configuration.nix
sed -i 's:%adminPassword%:'"$ADMIN_PASSWORD"':g' /mnt/etc/nixos/configuration.nix

log "Nix install"
nixos-install

log "Creating Desktop shortcuts"
mkdir -p /mnt/home/rmi/Desktop
mkdir -p /mnt/home/rmi/.config/codeblocks
cp /home/nixos/default.conf /mnt/home/rmi/.config/codeblocks/
#cat > /mnt/home/rmi/Desktop/contest.desktop <<EOF
#[Desktop Entry]
#
#Type=Link
#Version=1.0
#
#Name=Contest Site
#Comment=Open the contest platform in the browser
#URL=http://cms.lbi.ro:8888
#Icon=/etc/nixos/boot.png
#EOF
#chmod 555 /mnt/home/rmi/Desktop/contest.desktop
cat > /mnt/home/rmi/Desktop/README.txt <<EOF
Welcome, RMI contestant!

Here is some information you may find useful.

If the virtual machine content is smaller than the window, try to resize the virtual machine, or enter full screen mode.

The time displayed is in UTC.

To change the keyboard layout:
- Go to Applications (top-left corner) -> Settings -> Keyboard
- Click the Layout tab
- Uncheck "Use system defaults"
- Click on "English (US)"
- Click the "Edit" button and select your preferred layout.

You can find all text editors and IDEs in the Applications menu in the top-left corner,
in the Development section.

You can open Firefox either by clicking the globe icon on the dock
in the bottom of the screen, or by finding it in the Applications menu.
You will receive the address to the contest server from your team leader or proctor.

You can find the C++ Reference in the contest interface by clicking the "Documentation" link once the
contest starts.

Good luck!
EOF
chmod 444 /mnt/home/rmi/Desktop/README.txt
chown -R 1001 /mnt/home/rmi
