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
    #../../modules/home-assistant.nix
    ../../modules/mysql.nix
    ../../modules/minecraft.nix
    ../../modules/borgbackup.nix
    ../../modules/mealie.nix
    ../../modules/tailscale.nix
    ../../modules/caddy.nix
    #../../modules/bind.nix
    ../../modules/forgejo.nix
    ../../modules/paperless.nix
    ../../modules/binary-cache.nix
    ../../modules/jellyfin.nix
    ../../modules/containers-network.nix
    ../../modules/nextcloud.nix
    ../../modules/gatus.nix
    ../../modules/rustdesk.nix
    ../../modules/projects-test.nix
    ../../modules/stirling-pdf.nix
    ../../modules/redlib.nix
    ../../modules/copyparty.nix
    ../../modules/immich.nix
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
      useDHCP = false;
      networkmanager.enable = true;
      nameservers = ["1.1.1.1"];
      firewall.enable = true;
      firewall = {
        # Syncthing opens ports by itself
        allowedTCPPorts = [
          443 # https
          5000 # binary cache
        ];
        allowedUDPPorts = [
          443 # https
        ];
      };
      extraHosts = ''
        10.10.10.150 quesada.container
        10.10.10.150 door.container
        77.90.6.241 door.vps
        10.10.100.200 quesada.hp-laptop
      '';
    };

    services.resolved = {
      enable = true;
      dnssec = "true";
      fallbackDns = ["8.8.8.8"];
    };

    networking.nat.enable = true;
    networking.nat.internalInterfaces = [
      "ve-+"
      "vb-+"
      "veth+"
      "cbr"
      "enp34s0"
      "jellyfin-wg"
    ];
    networking.nat.externalInterface = "wlo1";
    networking.nat.internalIPs = [
      "10.10.10.100/24"
    ];

    networking.networkmanager.unmanaged = [
      "interface-name:ve-*"
      "interface-name:vb-*"
      "interface-name:veth*"
      "interface-name:cbr"
      "interface-name:enp34s0"
    ];

    services.kea.dhcp4 = {
      enable = true;
      settings = {
        interfaces-config = {
          interfaces = [
            "enp34s0"
          ];
        };
        subnet4 = [
          {
            id = 2;
            subnet = "10.10.100.0/24";
            interface = "enp34s0";
            pools = [
              {
                pool = "10.10.100.200 - 10.10.100.210";
              }
            ];
            option-data = [
              {
                name = "routers";
                data = "10.10.100.100";
              }
              {
                name = "domain-name-servers";
                data = "194.242.2.4";
              }
            ];
          }
        ];
      };
    };

    # ash drive
    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTR{idVendor}=="8564", ATTR{idProduct}=="1000", MODE="0660", OWNER="alberand"
    '';

    services.openssh.settings.AllowUsers = ["alberand"];

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
      extraGroups = [
        "wheel"
        "sudo"
        "libvirtd"
        "networkmanager"
        "wireshark"
        "disk"
        "dialout"
        "nextcloud-usb-sync"
      ];
      openssh.authorizedKeys.keyFiles = [
        ../../secrets/nothing_ed25519.pub
      ];
    };

    system.activationScripts = {
      text = ''
        mkdir -p /export
      '';
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
          "quesada" = {
            id = "N5L5J3F-PCNTF24-GRHGOCL-3EZ3GY2-YB5FG7U-ZAZUZUF-D65MMXS-5AJKRQU";
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
          "quesada-photos" = {
            path = "/media/photos/quesada";
            devices = ["quesada"];
          };
        };
      };
    };

    networking = {
      nftables = {
        enable = true;
        ruleset = ''
          table ip nat {
            chain PREROUTING {
              type nat hook prerouting priority dstnat; policy accept;
              iifname "tailscale0" tcp dport 4242 dnat to 10.10.10.69:4242
            }
          }
        '';
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = ["kvart"];
      ensureUsers = [
        {
          name = "kvart";
          ensureDBOwnership = true;
        }
      ];
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

    users.users.nextcloud-usb-sync = {
      isNormalUser = true;
      description = "User to sync nextcloud dir to USB flash drive";
      uid = 3400;
      group = "nextcloud-usb-sync";
    };
    users.groups.nextcloud-usb-sync.gid = 3400;

    services.davfs2.enable = true;
    age.secrets.davfs = {
      file = ../../secrets/davfs.age;
      path = "/etc/davfs2/secrets";
    };

    fileSystems = let
      davfs-config = pkgs.writeTextFile {
        name = "davfs-config";
        text = ''
          use_locks 0
        '';
      };
    in {
      # https://github.com/NixOS/nixpkgs/issues/24570
      "/export/alberand" = {
        device = "/home/alberand/Share/local";
        options = ["bind"];
      };

      "/mnt/usb" = {
        device = "/dev/disk/by-uuid/04E7-3687";
        fsType = "auto";
        options = [
          "rw"
          "uid=nextcloud-usb-sync"
          "gid=nextcloud-usb-sync"
          "umask=002"
          "noauto"
          "nofail"
          "x-systemd.automount"
          "x-systemd.idle-timeout=2"
          "x-systemd.device-timeout=2"
        ];
      };
      "/mnt/nextcloud" = {
        device = "https://files.alberand.com/remote.php/dav/files/nextcloud-usb-sync";
        fsType = "davfs";
        options = [
          "conf=${davfs-config}"
          "rw"
          "uid=nextcloud-usb-sync"
          "gid=nextcloud-usb-sync"
          "umask=002"
          "noauto"
          "nofail"
          "x-systemd.automount"
          "x-systemd.idle-timeout=2"
          "x-systemd.device-timeout=2"
        ];
      };
    };

    systemd = {
      timers = {
        "nextcloud-usb-sync" = {
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = "*-*-* *:*:0/10";
            Unit = "nextcloud-usb-sync.service";
            Persistent = true;
          };
        };
      };
      services = {
        "nextcloud-usb-sync" = {
          serviceConfig = {
            Type = "oneshot";
            User = "nextcloud-usb-sync";
            Group = "nextcloud-usb-sync";
            DynamicUser = false;
          };
          unitConfig = {
            ConditionPathExists = "/mnt/usb/flash.lock";
          };
          script = builtins.readFile ./configs/nextcloud-usb-sync.sh;
        };
      };
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
