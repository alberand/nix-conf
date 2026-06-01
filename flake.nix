{
  description = "Tower";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    unstablepkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    redhat.url = "gitlab:alberand-rh/redhat-nixos-workstation";
    agenix.url = "github:ryantm/agenix";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    copyparty.url = "github:9001/copyparty";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    unstablepkgs,
    home-manager,
    nixos-hardware,
    redhat,
    agenix,
    disko,
    impermanence,
    deploy-rs,
    copyparty,
    noctalia,
  }: let
    system = "x86_64-linux";
    unstable = import unstablepkgs {
      inherit system;
      config.allowUnfree = true;
    };
    overlay = (
      final: prev: {
        # To get 1.21.8 (5 Oct 2025)
        minecraft-server = unstable.minecraft-server;
        revumatic = redhat.packages."${system}".revumatic;
        koji = redhat.packages."${system}".koji;
        kerneloscope = redhat.packages."${system}".kerneloscope;
        beaker-client = redhat.packages."${system}".beaker-client;
        kup = redhat.packages."${system}".kup;
        xfstestsdb = redhat.packages."${system}".xfstestsdb;
        xournalpp = unstable.xournalpp;
        jujutsu = unstable.jujutsu;
        # Want version 1.6.2
        pocket-id = unstable.pocket-id;
        claude = redhat.packages."${system}".claude;
      }
    );
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        overlay
        copyparty.overlays.default
      ];
    };

    lib = nixpkgs.lib;
  in rec {
    overlays.default = overlay;

    nixosModules.redhat-home = (import ./machines/thinky/home.nix) {
      inherit agenix noctalia;
    };

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
            home-manager.users.alberand = pkgs.callPackage (import ./machines/nixxy/home.nix) {
              inherit noctalia;
            };
          }
          agenix.nixosModules.default
          {
            environment.systemPackages = [
              agenix.packages.${system}.default
              noctalia.packages.${system}.default
            ];
          }
          copyparty.nixosModules.default
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
            home-manager.users.aalbersh = pkgs.callPackage (import ./machines/thinky/home.nix) {
              inherit agenix noctalia;
            };
          }
          agenix.nixosModules.default
          {
            environment.systemPackages = [
              agenix.packages.${system}.default
              noctalia.packages.${system}.default
            ];
          }
        ];
      };

      door = lib.nixosSystem {
        inherit pkgs;
        inherit system;

        modules = [
          disko.nixosModules.disko
          agenix.nixosModules.default
          impermanence.nixosModules.impermanence
          ./machines/door/configuration.nix
          {
            environment.systemPackages = [agenix.packages.${system}.default];

            disabledModules = [
              # Want version 1.6.2
              "services/security/pocket-id.nix"
            ];

            imports = [
              "${unstablepkgs}/nixos/modules/services/security/pocket-id.nix"
            ];
          }
        ];
      };

      quesada = lib.nixosSystem {
        inherit pkgs;
        inherit system;

        modules = [
          disko.nixosModules.disko
          agenix.nixosModules.default
          impermanence.nixosModules.impermanence
          ./machines/quesada/configuration.nix
          {
            environment.systemPackages = [agenix.packages.${system}.default];
          }
        ];
      };
    };

    apps.${system} = let
      makeVmApp = host: let
        hostname = nixosConfigurations.${host}.config.networking.hostName;
        vm = nixosConfigurations.${host}.config.system.build.vm;
      in {
        type = "app";
        program = "${vm}/bin/run-${hostname}-vm";
      };
    in {
      quesada = makeVmApp "quesada";
      door = makeVmApp "door";
    };

    # Deploy with
    # nix run github:serokell/deploy-rs .#quesada
    deploy.nodes = {
      quesada = {
        hostname = "quesada.container";
        sshUser = "alberand";
        interactiveSudo = true;
        autoRollback = true;
        remoteBuild = false;
        activationTimeout = 600;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.quesada;
        };
      };

      door = {
        hostname = "door.vps";
        sshUser = "deploy";
        sshOpts = [
          "-i"
          "/home/alberand/.ssh/id_ed25519.pub"
        ];
        interactiveSudo = false;
        autoRollback = false;
        remoteBuild = false;
        activationTimeout = 600;
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.door;
        };
      };
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
