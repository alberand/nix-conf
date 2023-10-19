{
  description = "Tower";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    unstablepkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    revumatic.url = "gitlab:alberand-rh/revumatic";
    revumatic.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, unstablepkgs, home-manager, nixos-hardware,
    revumatic }:
  let
    system = "x86_64-linux";
    unstable = import unstablepkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [(final: prev: {
        # Example of bringing in an unstable package:
        minecraft-server = unstable.minecraft-server;
        revumatic = revumatic.packages."${system}".revumatic;
      })];
    };

    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      nixxy = lib.nixosSystem {
        inherit pkgs;
        inherit system;

        modules = [
          ./machines/nixxy/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.alberand = import ./machines/nixxy/home.nix;
          }
        ];
      };
      thinky = lib.nixosSystem {
        inherit pkgs;
        inherit system;

        modules = [
          ./machines/thinky/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t14s
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.aalbersh = import ./machines/thinky/home.nix;
          }
        ];
      };
    };
  };
}
