{
  description = "Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    nix-flatpak.url = "github:gmodena/nix-flatpak/";

#     xdg-termfilepickers.url = "github:Guekka/xdg-desktop-portal-termfilepickers/195ba6bb4a4f0224b0e749f2198fc88696be6383";
  };

  outputs = { nixpkgs, home-manager, catppuccin, neovim-nightly-overlay, nix-flatpak, ... }: {
    nixosConfigurations.yoops = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix # Include the results of the hardware scan

        home-manager.nixosModules.home-manager
        {
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = {
            inherit neovim-nightly-overlay;
          };

          home-manager.users.yoops = {
            imports = [
              ./home.nix

              catppuccin.homeModules.catppuccin
	      nix-flatpak.homeManagerModules.nix-flatpak
#               xdg-termfilepickers.homeManagerModules.default
            ];
          };
        }
      ];
    };
  };
}

