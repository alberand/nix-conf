{ pkgs, lib, config, ... }:

with lib; {
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
  ];

  config = rec {
    #services.qemuGuest.enable = true;

    boot = {
      kernelParams = [
        # consistent eth* naming
        "net.ifnames=0"
        "biosdevnames=0"
        "boot.shell_on_fail"
        #"console=ttyS0,115200n8"
        #"console=ttyS0"
      ];

      crashDump.enable = true;
    };

    virtualisation = {
      diskSize = 8000; # MB
      memorySize = 2048; # MB
      graphics = true;
      writableStoreUseTmpfs = false;
      useDefaultFilesystems = true;

      sharedDirectories = {
        results = {
          source = "/home/alberand/Projects/work-machine/secrets/etc/openvpn";
          target = "/etc/openvpn";
        };
        results = {
          source = "/home/alberand/Projects/work-machine/secrets/.secrets";
          target = "/home/aalbersh/.secrets";
        };
        results = {
          source = "/home/alberand/Projects/work-machine/secrets/.ssh";
          target = "/home/aalbersh/.ssh";
        };
      };

      qemu = {
        options = [
          "-vga qxl"
        ];
        networkingOptions = [
          "-device e1000,netdev=network0,mac=00:00:00:00:00:00"
          "-netdev tap,id=network0,ifname=tap0,script=no,downscript=no"
        ];
      };
    };

    networking.firewall.enable = false;
    networking.hostName = "redhat";
    networking.useDHCP = true;
    networking.interfaces.eth1 = {
      ipv4.addresses = [{
        address = "192.168.10.3";
        prefixLength = 24;
      }];
    };

    services.openssh.enable = true;
    #services.openssh.settings.permitRootLogin = "yes";

    # Give root an empty password to ssh in.
    #users.extraUsers.root.initialHashedPassword = "";
    #services.getty.autologinUser = lib.mkDefault "root";
    users.mutableUsers = true;

    system.stateVersion = "23.05";
  };
}
