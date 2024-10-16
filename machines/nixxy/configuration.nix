{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../options.nix
    ../../modules/common.nix
    ../../modules/wireguard.nix
    ../../modules/podman-deluge.nix
    ../../modules/nginx.nix
    ../../modules/grafana.nix
    ../../modules/qemu-guest-network.nix
    ../../modules/home-assistant.nix
    ../../modules/mysql.nix
    ../../modules/minecraft.nix
    ../../modules/borgbackup.nix
    ../../modules/build-machines.nix
    ../../modules/photoprism.nix
    ../../modules/jellyfin-tunnel.nix
    ../../modules/tandoor.nix
    ../../modules/tailscale.nix
    ../../modules/caddy.nix
  ];

  config = {
    user = "alberand";
    # Use the systemd-boot EFI boot loader.
    boot.loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        enableCryptodisk = true;
        device = "nodev";
      };
    };

    boot.initrd.luks.devices = {
      crypted = {
        device = "/dev/disk/by-uuid/4e62f0f4-6b77-4947-b031-c7d5652a8eb3";
        preLVM = true;
      };
    };
    boot.initrd.kernelModules = ["amdgpu"];

    # Vulkan API/OpenCL API/Modern AMD Graphics Core Next (GCN) GPUs
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
        amdvlk
      ];
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
          22 # ssh
          config.services.minecraft-server.serverProperties.server-port
          config.networking.wg-quick.interfaces.wg0.listenPort
          55686 # jellyfin
          443 # https
          1194 # OpenVPN
          8123 # home-assistant
          111 # NFS
          2049 # NFS
          5000 # testing my pet-projects
        ];
        allowedUDPPorts = [
          53 # dns
          config.services.minecraft-server.serverProperties.server-port
          config.networking.wg-quick.interfaces.wg0.listenPort
          443 # https
          1194 # OpenVPN
          111 # NFS
          2049 # NFS
        ];
      };
    };

    networking.nat.enable = true;
    networking.nat.internalInterfaces = ["ve-+"];
    networking.nat.externalInterface = "enp34s0";
    networking.networkmanager.unmanaged = ["interface-name:ve-*"];

    # ash drive
    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTR{idVendor}=="8564", ATTR{idProduct}=="1000", MODE="0660", OWNER="alberand"
    '';

    # Media group to access media storage
    users.groups.media = {
      name = "media";
      gid = 8096;
      members = ["alberand" "jellyfin" "deluge" "radarr" "jackett"];
    };

    users.users.deluge = {
      isNormalUser = true;
      description = "Deluge";
      extraGroups = ["media"];
      uid = 1002;
    };

    users.users.jellyfin = {
      description = "JellyFin";
      extraGroups = ["media" "render" "video"];
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.alberand = {
      isNormalUser = true;
      description = "Andrey Albershteyn";
      uid = 1000;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "sudo"
        "libvirt"
        "networkmanager"
        "wireshark"
        "disk"
      ];
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
      # video
      mesa
      mesa-demos
      vulkan-tools
      vulkan-headers
      vulkan-loader
      radeontop
      libgdiplus
      jellyfin-ffmpeg
      rocm-opencl-runtime
      libva
      radeontop
      jdk17
    ];

    # Enable sound.
    sound.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # xdg-desktop-portal works by exposing a series of D-Bus interfaces
    # known as portals under a well-known name
    # (org.freedesktop.portal.Desktop) and object path
    # (/org/freedesktop/portal/desktop). The portal interfaces include
    # APIs for file access, opening URIs, printing and others.
    services.dbus.enable = true;
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      # gtk portal needed to make gtk apps happy
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
      };
    };

    # Enable WeeChat to run as service with attached 'screen' session To
    # attach use: screen -x weechat/wc
    services.weechat.enable = true;
    services.weechat.sessionName = "wc";

    security.rtkit.enable = true;
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    virtualisation = {
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        # Create a `docker` alias for podman, to use it as a
        # drop-in replacement
        dockerCompat = true;
      };
    };

    programs.kdeconnect.enable = true;

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
      user = "alberand";
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
        };
      };
    };

    programs.ccache.enable = true;
    programs.ccache.cacheDir = "/var/cache/ccache";
    programs.ccache.packageNames = ["linux"];

    services.nfs.server.enable = true;
    # TODO probably need to make it more safe regarding the permission
    services.nfs.server.exports = ''
      /export          192.168.0.101(rw,fsid=0,no_subtree_check)
      /export/alberand 192.168.0.101(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=1000,anongid=100)
    '';

    systemd.user.services.kanshi = {
      enable = true;
      description = "Kanshi daemon (monitor configurator)";
      wantedBy = [];
      after = [];
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
      };
    };

    services.radarr = {
      enable = true;
    };

    services.jackett = {
      enable = true;
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?
  };
}
