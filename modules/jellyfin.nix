{
  pkgs,
  config,
  ...
}: {
  networking = {
    firewall.allowedTCPPorts = [
      55686
    ];
    nftables = {
      enable = true;
      ruleset = ''
        table ip nat {
          chain PREROUTING {
            type nat hook prerouting priority dstnat; policy accept;
            iifname "tailscale0" tcp dport 55686 dnat to 10.10.10.30:55686
          }
        }
      '';
    };
  };

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
        hostPath = "/media/var/lib";
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      hardware.graphics = {
        enable = true;
      };

      users.users.media = {
        isNormalUser = true;
        description = "Movies & Shows media user";
        group = "media";
        uid = 3000;
      };

      users.groups.media = {
        name = "media";
        gid = 3000;
        members = ["jellyfin" "sonarr" "radarr" "jackett"];
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

      system.stateVersion = "25.05";

      networking = {
        firewall = {
          enable = true;
          # TODO I have non-standard port for Jellyfin, revert it
          allowedTCPPorts = [
            55686
          ];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;
    };
  };

  # Media group to access media storage
  users.users.media = {
    isNormalUser = true;
    description = "Movies & Shows media user";
    group = "media";
    uid = 3000;
  };

  users.groups.media = {
    name = "media";
    gid = 3000;
    members = [config.user "media"];
  };

  # binhex/arch-delugevpn uses iptables 'filter' table
  boot.kernelModules = ["iptable_filter"];

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
        DELUGE_DAEMON_LOG_LEVEL = "trace";
        DELUGE_WEB_LOG_LEVEL = "trace";
        DEBUG = "true";
        UMASK = "027";
        TZ = "Europe/London";
        DELUGE_ENABLE_WEBUI_PASSWORD = "no";
      };
    };
  };
}
