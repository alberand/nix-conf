{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../options.nix
    ../../modules/common.nix
    #../../modules/wireguard.nix
    ../../modules/nginx.nix
    ../../modules/grafana.nix
    ../../modules/qemu-guest-network.nix
    ../../modules/home-assistant.nix
    ../../modules/mysql.nix
    ../../modules/minecraft.nix
    ../../modules/borgbackup.nix
    ../../modules/photoprism.nix
    ../../modules/tandoor.nix
    ../../modules/tailscale.nix
    ../../modules/caddy.nix
    ../../modules/bind.nix
    ../../modules/forgejo.nix
    ../../modules/paperless.nix
    ../../modules/binary-cache.nix
    ../../modules/jellyfin.nix
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

      initrd.kernelModules = ["amdgpu"];
      initrd.luks.devices = {
        crypted = {
          device = "/dev/disk/by-uuid/4e62f0f4-6b77-4947-b031-c7d5652a8eb3";
          preLVM = true;
        };
      };
    };

    # Vulkan API/OpenCL API/Modern AMD Graphics Core Next (GCN) GPUs
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [amdvlk];
    };

    networking = {
      hostName = "nixxy";
      # Pick only one of the below networking options.
      networkmanager.enable = true;
      networkmanager.dns = "default";
      #defaultGateway = "192.168.0.1";
      interfaces.enp34s0.useDHCP = true;
      firewall.enable = true;
      firewall = {
        # Syncthing opens ports by itself
        allowedTCPPorts = [
          53 # dns
          443 # https
          1194 # OpenVPN
          # 111 # NFS
          # 2049 # NFS
          5000 # binary cache
          6969 # testing my pet-projects
          4242 # nemambyt test container
        ];
        allowedUDPPorts = [
          53 # dns
          443 # https
          1194 # OpenVPN
          # 111 # NFS
          # 2049 # NFS
        ];
      };
    };

    networking.nat.enable = true;
    networking.nat.internalInterfaces = ["ve-+"];
    networking.nat.externalInterface = "wlo1";
    networking.networkmanager.unmanaged = ["interface-name:ve-*"];

    # ash drive
    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTR{idVendor}=="8564", ATTR{idProduct}=="1000", MODE="0660", OWNER="alberand"
    '';

    services.openssh.settings.AllowUsers = ["aalbersh"];

    users.users.nixremote = {
      isNormalUser = true;
      description = "Nix remote builder";
      uid = 1003;
      openssh.authorizedKeys.keyFiles = [
        ../../secrets/nixbuilder_ed25519.pub
      ];
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.alberand = {
      isNormalUser = true;
      description = "Andrey Albershteyn";
      uid = 1000;
      shell = pkgs.zsh;
      extraGroups = ["wheel" "sudo" "libvirtd" "networkmanager" "wireshark" "disk"];
    };

    system.activationScripts = {
      text = ''
        mkdir -p /export
      '';
    };

    # https://github.com/NixOS/nixpkgs/issues/24570
    fileSystems."/export/alberand" = {
      device = "/home/alberand/Share/local";
      options = ["bind"];
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      wine
      wine-wayland
      yt-dlp
      # video
      mesa
      mesa-demos
      vulkan-tools
      vulkan-headers
      vulkan-loader
      radeontop
      libgdiplus
      libva
      radeontop
      docker-compose
      (writeShellScriptBin "workfox"
        "exec -a $0 ${firefox}/bin/firefox -P RedHat $@")
      openrgb-plugin-effects
    ];

    virtualisation = {
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        # Create a `docker` alias for podman, to use it as a
        # drop-in replacement
        dockerCompat = true;
      };
    };

    services.syncthing = {
      enable = true;
      dataDir = "/home/alberand/Share";
      configDir = "/home/alberand/.config/syncthing";
      # overrides any devices added or deleted through the WebUI
      overrideDevices = true;
      # overrides any folders added or deleted through the WebUI
      overrideFolders = false;
      # Open firewall ports
      openDefaultPorts = true;
      user = config.user;
      group = "users";
      settings = {
        devices = {
          "lonmoun" = {
            id = "BHZVVJE-BKYAHGR-6ET6T2T-O7SRFSC-AKQEOP3-KYR4JME-ARSWMAB-HQSRBQL";
          };
          "nothing-phone" = {
            id = "74LMGV3-VGBB6J7-CT7LRHY-CANX5WF-UOVYYXG-762UH5M-6HFZKLB-AXNP2QW";
          };
        };

        folders = {
          "Documents" = {
            path = "/home/alberand/Share/Documents";
            devices = ["lonmoun" "nothing-phone"];
          };
          "Photos" = {
            path = "/media/photos/nothing-phone";
            devices = ["lonmoun" "nothing-phone"];
          };
        };
      };
    };

    # services.nfs.server.enable = true;
    # # TODO probably need to make it more safe regarding the permission
    # services.nfs.server.exports = ''
    #   /export          192.168.0.101(rw,fsid=0,no_subtree_check)
    #   /export/alberand 192.168.0.101(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=1000,anongid=100)
    # '';

    virtualisation.libvirtd.enable = true;

    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
      motherboard = "amd";
      server = {port = 6742;};
    };

    nix.settings.trusted-users = ["nixremote"];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.05"; # Did you read the comment?
  };
}
