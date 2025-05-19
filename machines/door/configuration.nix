{
  config,
  pkgs,
  ...
}: let
  domain = "door.alberand.com";
  # TODO
  public_ip = "";
in {
  imports = [
    ./hardware-configuration.nix
    ../../options.nix
    ((import ./headscale.nix) {inherit domain public_ip;})
    ((import ./dns.nix) {inherit domain public_ip;})
  ];

  config = {
    user = "alberand";

    boot = {
      loader = {
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = true;
        grub = {
          enable = true;
          efiSupport = true;
          enableCryptodisk = true;
          device = "nodev";
        };
      };

      initrd.luks.devices = {
        crypted = {
          # TODO this is different
          device = "/dev/disk/by-uuid/4e62f0f4-6b77-4947-b031-c7d5652a8eb3";
          preLVM = true;
        };
      };
    };

    networking = {
      hostName = "door";
      # Pick only one of the below networking options.
      networkmanager.enable = true;
      networkmanager.dns = "default";
      interfaces.eth0.useDHCP = true;
      firewall.enable = true;
      firewall = {
        # Syncthing opens ports by itself
        allowedTCPPorts = [
          53 # dns
          22 # ssh
          443 # https
        ];
        allowedUDPPorts = [
          53 # dns
          443 # https
        ];
      };
    };

    networking.nat.enable = true;
    networking.nat.internalInterfaces = ["ve-+"];
    networking.nat.externalInterface = "eth0";
    networking.networkmanager.unmanaged = ["interface-name:ve-*"];

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.alberand = {
      isNormalUser = true;
      uid = 1000;
      shell = pkgs.zsh;
      extraGroups = ["wheel" "sudo" "networkmanager"];
    };

    environment.systemPackages = with pkgs; [
    ];

    system.stateVersion = "24.11";
  };
}
