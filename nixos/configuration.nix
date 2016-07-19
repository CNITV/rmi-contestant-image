{ config, pkgs, ... }:

{
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Enable disk
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "discard" "compress=lzo" ];
  };

  # Install minimal packages needed for provisioning
  environment.systemPackages = with pkgs; [
    git
  ];

  # Turn off mutable users so `nixos-install` does not prompt to set a password
  users.mutableUsers = false;

  # Create my personal user
  # The password should be changed later
  users.extraUsers.kiba = {
    description = "Kiba Fox";
    isNormalUser = true;
    initialPassword = "packer";
    extraGroups = [
      "wheel"
    ];
    uid = 1000;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  virtualisation.virtualbox.guest.enable = true;
}
