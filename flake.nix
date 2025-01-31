{
  description = "Tower";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    unstablepkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    redhat = {
      url = "gitlab:alberand-rh/redhat-nixos-workstation";
      inputs.nixpkgs.follows = "unstablepkgs";
    };
    agenix.url = "github:ryantm/agenix";
  };

  outputs = {
    self,
    nixpkgs,
    unstablepkgs,
    home-manager,
    nixos-hardware,
    redhat,
    agenix,
  }: let
    system = "x86_64-linux";
    unstable = import unstablepkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [
        "squid-6.10"
      ];
      overlays = [
        (final: prev: {
          # Example of bringing in an unstable package:
          minecraft-server = unstable.minecraft-server;
          revumatic = redhat.packages."${system}".revumatic;
          koji = redhat.packages."${system}".koji;
          kerneloscope = redhat.packages."${system}".kerneloscope;
          beaker-client = redhat.packages."${system}".beaker-client;
          kup = redhat.packages."${system}".kup;
          xfsprogs-release = redhat.packages."${system}".xfsprogs-release;
          xfstestsdb = redhat.packages."${system}".xfstestsdb;
          # Can be removed soon https://github.com/NixOS/nixpkgs/issues/371837
          jackett = unstable.jackett;
        })
      ];
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
          agenix.nixosModules.default
          {
            environment.systemPackages = [agenix.packages.${system}.default];
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
          agenix.nixosModules.default
          {
            environment.systemPackages = [agenix.packages.${system}.default];
          }
        ];
      };
    };
  };
}
