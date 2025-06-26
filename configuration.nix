# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Pay attention to if you want disk-config.nix or the following for luks
    ./disk-config2.nix
    ./users.nix
    ./networking.nix
    ./boot.nix
    ./zram.nix
    # ./sops.nix
    # ./impermanence.nix
    # ./impermanenceLUKS.nix
  ];
  # After formatting with disko, the following is more robust
  # boot.initrd.luks.devices = {
  #   cryptroot = {
  #     device = "/dev/disk/by-partlabel/luks";
  #     allowDiscards = true;
  #     preLVM = true;
  #   };
  # };

  # Change me!
  networking.hostName = "nixos"; # Define your hostname.

  # Custom Options
  custom = {
    boot.enable = true;
    users.enable = true;
    zram.enable = true;
  };
  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
  ];

  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
