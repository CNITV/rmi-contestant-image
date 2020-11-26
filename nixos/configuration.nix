{ config, pkgs, ... }:

let
  vianuBreezePlymouth = pkgs.plasma5.breeze-plymouth.override {
    logoFile = ./boot.png;
    logoName = "vianu";
    osName = "RMI_OS";
    osVersion = "2020";
  };
in {
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.copyKernels = true;
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "628d3821";

  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 45;
  };

  users.mutableUsers = true;
  users.users.root.initialHashedPassword = "%adminPassword%";

  users.extraUsers."%adminUsername%" = {
    description = "RMI Overlord";
    isNormalUser = true;
    initialHashedPassword = "%adminPassword%";
    extraGroups = [
      "wheel"
    ];
    uid = 1000;
  };

  nix.trustedUsers = [ "%adminUsername%" ];

  users.extraUsers."rmi" = {
    description = "RMI Contestant";
    isNormalUser = true;
    initialPassword = "rmi";
    uid = 1001;
  };

  services.openssh.enable = true;

  virtualisation.virtualbox.guest.enable = true;
  virtualisation.vmware.guest.enable = true;

  boot.plymouth.enable = true;
  boot.plymouth.themePackages = [ vianuBreezePlymouth ];

  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.defaultSession = "xfce";

  documentation.man.generateCaches = true;
  documentation.dev.enable = true;
  documentation.nixos.enable = false;

  programs.gnome-terminal.enable = true;

  nixpkgs.config.allowUnfree = true; # for firefox-bin
  environment.systemPackages = with pkgs; [
    firefox-bin

    codeblocks
    emacs
    vim
    eclipses.eclipse-cpp
    geany
    sublime3
    neovim

    python3
    ruby

    gcc7
    gdb
    ddd
    valgrind
    gnumake
    stdman

    gnome3.file-roller
    xfce.thunar-archive-plugin
    byobu
    tmux
    htop
    evince
    konsole

    anydesk
  ];

  system.stateVersion = "20.09";
}
