{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.boot;
in {
  options.custom.boot = {
    # enabled with `custom.boot.enable = true;` in configuration.nix
    enable = lib.mkEnableOption "Enable the Boot Module";
  };

  # If `custom.boot.enable = true;` then add the following
  config = lib.mkIf cfg.enable {
    boot = {
      # LinuxZen Kernel
      kernelPackages = pkgs.linuxPackages_zen;
      consoleLogLevel = 3;
      # /tmp in RAM wiped on reboot
      tmp = {
        useTmpfs = true;
        tmpfsSize = "50%";
      };
      # disable wifi powersave
      extraModprobeConfig = ''
        options iwlmvm  power_scheme=1
        options iwlwifi power_save=0
      '';
      kernelParams = [
        "quiet"
        "systemd.show_status=auto"
        "rd.udev.log_level=3"
        "plymouth.use-simpledrm"
      ];
      kernel.sysctl = {
        "vm.max_map_count" = 2147483642;
      };
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = true;
          configurationLimit = 20;
          consoleMode = lib.mkDefault "max";
        };
      };
      plymouth = {
        enable = true;
        theme = "rings";
        themePackages = with pkgs; [
          (adi1090x-plymouth-themes.override {
            selected_themes = ["rings"];
          })
        ];
      };
      # Enable "Silent Boot"
      # consoleLogLevel = 0;
      # initrd.verbose = false;
      # kernelParams = [
      #   "quiet"
      #   "splash"
      #   "boot.shell_on_fail"
      #   "loglevel=3"
      #   "rd.systemd.show_status=false"
      #   "rd.udev.log_level=3"
      #   "udev.log_priority=3"
      # ];
      # Hide the OS choice for bootloaders.
      # It's still possible to open the bootloader list by pressing any key
      # It will just not appear on screen unless a key is pressed
      # loader.timeout = 0;
    };
    # environment.systemPackages = with pkgs; [greetd.tuigreet];
  };
}
