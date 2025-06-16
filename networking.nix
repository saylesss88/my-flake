{...}: {
  networking = {
    networkmanager.enable = true;
    # firewall = {
    #   enable = true;
    # allowedTCPPorts = [80 443 25];
    # allowedUDPPorts = [53 22];
    # };
    enableIPv6 = true;
  };
}
