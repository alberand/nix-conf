{
  description = "Tower";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, unstable, home-manager }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [(final: prev: {
        # Example of bringing in an unstable package:
        photoprism = unstable.legacyPackages.${prev.system}.photoprism;
      })];
    };

    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      nixxy = lib.nixosSystem {
        inherit pkgs;
        inherit system;

        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.alberand = import ./home.nix;
          }
        ];
      };
    };
  };
}
