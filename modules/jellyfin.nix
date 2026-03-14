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

  boot.kernelPatches = [
    {
      name = "iptables-deluge-config";
      patch = null;
      extraConfig = ''
        NETFILTER_XTABLES_LEGACY y
        NETFILTER_XT_NAT m
        IP_NF_IPTABLES_LEGACY m
        IP_NF_FILTER m
        IP_NF_TARGET_REJECT m
        IP_NF_NAT m
        IP_NF_MANGLE m
        IP6_NF_IPTABLES_LEGACY m
        IP6_NF_FILTER m
        IP6_NF_TARGET_REJECT m
        IP6_NF_MANGLE m

        NETFILTER y
        NETFILTER_ADVANCED y
        NETFILTER_XTABLES m
        IP_NF_IPTABLES m
        IP6_NF_IPTABLES m
        NETFILTER_XT_MATCH_STATE m
        NETFILTER_XT_MATCH_CONNTRACK m
        NETFILTER_XT_TARGET_LOG m
        NETFILTER_XT_TARGET_MASQUERADE m
        NF_CONNTRACK m
        NF_NAT m
      '';
    }
  ];

  # binhex/arch-delugevpn uses iptables 'filter' table
  boot.kernelModules = ["iptable_filter"];
  networking.extraHosts = "10.10.10.50 deluge.containers";

  virtualisation.oci-containers.containers = {
    "deluge" = {
      image = "binhex/arch-delugevpn";
      autoStart = true;
      networks = ["cnet"];
      ports = [
        "8112:8112"
        "8118:8118"
        "58846:58846"
        "58946:58946"
      ];

      extraOptions = [
        # Limit memory use as deluged eating crazy amounts of memory over time
        "--memory=2048m"
        "--ip=10.10.10.50"
        "--privileged=true"
        ''--sysctl="net.ipv4.conf.all.src_valid_mark=1"''
        ''--sysctl="net.ipv4.ip_forward=1"''
      ];

      volumes = [
        "/media:/media"
        "/media/var/lib/deluge:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];

      environment = {
        PUID = "0";
        PGID = toString config.users.groups.media.gid;
        VPN_ENABLED = "yes";
        VPN_CLIENT = "wireguard";
        VPN_PROV = "custom";
        STRICT_PORT_FORWARD = "yes";
        ENABLE_PRIVOXY = "yes";
        LAN_NETWORK = "10.10.10.0/24";
        # DNS Watch #1 #3 Cloudflare #2 #4
        NAME_SERVERS = "84.200.69.80,1.1.1.1,84.200.70.40,1.0.0.1";
        DELUGE_DAEMON_LOG_LEVEL = "error";
        DELUGE_WEB_LOG_LEVEL = "error";
        DEBUG = "false";
        UMASK = "027";
        TZ = "Europe/London";
        DELUGE_ENABLE_WEBUI_PASSWORD = "no";
      };
    };
  };
}
