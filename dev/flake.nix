{
  description = "DevShell replacing Ansible provisioning";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    home-manager,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        username = "ghilston";
        pkgs = import nixpkgs {inherit system;};
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.zsh
            pkgs.git
            pkgs.stow
            pkgs.docker
            pkgs.flatpak
            pkgs.curl
            pkgs.wget
          ];
          shellHook = ''
            export SHELL=$(which zsh)
            if [ ! -d "$HOME/.oh-my-zsh" ]; then
              echo "Installing Oh My Zsh..."
              sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            fi
            if [ -d "$PWD/dotfiles" ]; then
              stow -d "$PWD/dotfiles" -t "$HOME" *
            fi
            echo "Welcome to your Nix dev environment!"
            exec zsh
          '';
        };

        # Activate with home-manager switch
        homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [./home.nix];
        };
      }
    );
}
