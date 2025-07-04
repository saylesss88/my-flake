{
  # Testing this is a test
  description = "Nix Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # impermanence.url = "github:nix-community/impermanence";
  };

  outputs = inputs @ {nixpkgs, ...}: {
    nixosConfigurations = {
      # Change me! Change `nixos` to chosen hostname
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          # inputs.impermanence.nixosModules.impermanence
        ];
      };
    };
  };
}
