{config, ...}: let
  uuid = 3000;
  port = 55686;
in {
  age.secrets.wg-private-file = {
    file = ../secrets/jellyfin-wg-client.age;
    mode = "400";
    owner = "root";
    group = "root";
  };

  networking = {
    firewall = {
      allowedTCPPorts = [
        port
      ];
      allowedUDPPorts = [
        config.networking.wg-quick.interfaces.jellyfin-wg.listenPort
      ];
    };
    wg-quick.interfaces = {
      jellyfin-wg = {
        address = ["10.20.10.2/24"];
        listenPort = 51820;
        privateKeyFile = config.age.secrets.wg-private-file.path;
        peers = [
          {
            publicKey = "dwXTUUzaKrApHoByhEv7FqqEK0n4Qe3G8ESoUbo6zC0=";
            allowedIPs = ["10.20.10.0/24"];
            endpoint = "77.90.6.241:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
    nftables = {
      enable = true;

      tables.services = {
        enable = true;
        family = "ip";
        content = ''
          chain PREROUTING {
            type nat hook prerouting priority dstnat; policy accept;
            iifname "jellyfin-wg" tcp dport 55686 dnat to 10.10.10.30:${builtins.toString port}
            iifname "wlo1" tcp dport 55686 dnat to 10.10.10.30:${builtins.toString port}
          }
        '';
      };
    };
  };

  users.users.media = {
    isNormalUser = true;
    description = "Movies & Shows media user";
    group = "media";
    uid = uuid;
    extraGroups = ["media"];
  };

  users.groups.media = {
    name = "media";
    gid = uuid;
  };

  systemd.tmpfiles.rules = [
    "d /media/movies      2755 media media -"
    "d /media/shows       2755 media media -"
    "d /media/music       2755 media media -"
    "d /media/in-progress 2755 media media -"
    "d /media/new         2755 media media -"
    "d /media/youtube     2755 media media -"
    "d /media/anime       2755 media media -"
    "d /media/nosee       2755 media media -"
  ];

  # TODO this need to be rootless container
  containers.jellyfin = {
    autoStart = true;
    ephemeral = true;
    # TODO do i need to set this?
    # privateUsers = "yes";
    privateNetwork = true;
    hostBridge = "cbr";
    hostAddress = "10.10.10.100";
    localAddress = "10.10.10.30/24";
    # TODO read how secure this is
    # https://github.com/systemd/systemd/issues/10960
    # https://github.com/NixOS/nixpkgs/issues/347056
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.resource-control.html
    # Not sure what exactly this char-drm does
    allowedDevices = [
      {
        modifier = "rw";
        node = "char-drm";
      }
      {
        modifier = "rw";
        node = "/dev/dri";
      }
      {
        modifier = "rw";
        node = "/dev/shm";
      }
    ];
    bindMounts = {
      # Sharing GPU for jellyfin transcoding
      "/dev/dri" = {
        hostPath = "/dev/dri";
        isReadOnly = false;
      };
      # All the media goes here (Linux ISO, DVD rips)
      "/media" = {
        hostPath = "/media";
        isReadOnly = false;
      };
      "/bigdata" = {
        hostPath = "/bigdata";
        isReadOnly = false;
      };
      # On the host jellyseerr config is stored at
      # /media/var/lib/jellyseerr/config. On the guest, jellyseerr has
      # DynamicUser enabled, that's means that service unit will have private
      # filesystem space for every user connected. This also migrates config
      # directory to /var/lib/private/jellyseerr
      #
      # We can not bind /media/var/lib/jellyseerr directly as systemd then won't
      # be able to move it to /private. Let's mount the whole directory,
      # assuming there's no other configs not intended for 'media' container.
      #
      # TODO This let container save all the data to /media, which is not
      # desired for backups
      "/var/lib" = {
        hostPath = "/media/cstate/media/var/lib";
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      nixpkgs.overlays = [
        (final: prev: {
          # Jackett quite often fails tests and break builds
          # https://github.com/NixOS/nixpkgs/issues/478145
          jackett = prev.jackett.overrideAttrs (_oldAttrs: {
            doCheck = false;
          });
        })
      ];

      hardware.graphics = {
        enable = true;
      };

      users.users.media = {
        isNormalUser = true;
        description = "Movies & Shows media user";
        group = "media";
        uid = uuid;
      };

      users.groups.media = {
        name = "media";
        gid = uuid;
        members = [
          "jellyfin"
          "sonarr"
          "radarr"
          "jackett"
          "lidarr"
        ];
      };

      environment.systemPackages = with pkgs; [
        libva-utils
        jellyfin-ffmpeg
      ];

      services.jellyfin = {
        enable = true;
        openFirewall = true;
        user = "media";
        group = "media";
      };

      systemd.services.jellyfin.serviceConfig = {
        MemoryAccounting = true;
        MemoryHigh = "8G";
        MemoryMax = "9G";
      };

      services.radarr = {
        enable = true;
        openFirewall = true;
        user = "media";
        group = "media";
      };

      services.jackett = {
        enable = true;
        openFirewall = true;
        user = "media";
        group = "media";
      };

      services.jellyseerr = {
        enable = true;
        port = 5055;
        openFirewall = true;
      };

      services.sonarr = {
        enable = true;
        openFirewall = true;
        user = "media";
        group = "media";
      };

      services.lidarr = {
        enable = true;
        openFirewall = true;
        user = "media";
        group = "media";
        settings.server.port = 8686;
      };

      system.stateVersion = "25.11";

      networking = {
        firewall = {
          enable = true;
          # TODO I have non-standard port for Jellyfin, revert it
          allowedTCPPorts = [
            port
          ];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;
    };
  };
}
