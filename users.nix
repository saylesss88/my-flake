{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    # Enabled with custom.users.enable = true; in `configuration.nix`
    custom.users.enable = lib.mkEnableOption "Enables users module";
  };

  config = lib.mkIf config.custom.users.enable {
    users.users = {
      # Change me!
      your-user = {
        homeMode = "755";
        isNormalUser = true;
        # Change me!
        # description = "gitUsername";
        # Change me! generate with `mkpasswd -m SHA-512 -s`
        # initialHashedPassword = "$6$knlskdQSQp4le3uiy..3$gAUAugTxAeHUpWKf6iwlkasdjf'lkajWNZRTtjbJ4X0PIjkIQOCcLcimOJe4Y0";

        extraGroups = [
          "networkmanager"
          "wheel"
          "libvirtd"
          "scanner"
          "lp"
          "root"
          # "your-user"
          "sudo"
        ];
        shell = pkgs.zsh;
        ignoreShellProgramCheck = true;
        packages = [
          pkgs.tealdeer
          pkgs.zoxide
          pkgs.mcfly
          pkgs.tokei
          pkgs.stow
        ];
      };
    };
  };
}
