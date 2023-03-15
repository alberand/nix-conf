{
	description = "Tower";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager }:
	let
		system = "x86_64-linux";
		pkgs = import nixpkgs {
			inherit system;
			config.allowUnfree = true;
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
