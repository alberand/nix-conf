{
  pkgs,
  config,
  ...
}: {
  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["10.10.10.2"];
      privateKeyFile = "/etc/jfwg/client.private";

      peers = [
        {
          publicKey = "MKrNqXfz4sMtRekE44eHLdS/epD0MRZDd/PslJilr1A=";
          allowedIPs = ["10.10.10.0/30"];
          endpoint = "89.221.212.102:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # TODO this need to be rootless container
  containers.jellyfin = {
    autoStart = true;
    ephemeral = true;
    bindMounts = {
      "/media" = {
        hostPath = "/media";
        isReadOnly = false;
      };
      "/var/lib/jellyfin" = {
        hostPath = "/media/var/lib/jellyfin";
        isReadOnly = false;
      };
      "/var/lib/jellyseerr" = {
        hostPath = "/media/var/lib/jellyseerr";
        isReadOnly = false;
      };
      "/var/lib/jackett" = {
        hostPath = "/media/var/lib/jackett";
        isReadOnly = false;
      };
      "/var/lib/radarr" = {
        hostPath = "/media/var/lib/radarr";
        isReadOnly = false;
      };
      "/var/lib/sonarr" = {
        hostPath = "/media/var/lib/sonarr";
        isReadOnly = false;
      };
      "/var/lib/deluge" = {
        hostPath = "/media/var/lib/deluge";
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
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
        nmap
        busybox
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
            58846
          ];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;
    };
  };

  #services.home-assistant.extraComponents = ["jellyfin"];

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
    members = [config.user "media" "jellyfin" "sonarr" "radarr" "jackett"];
  };

  users.users.deluge = {
    isNormalUser = true;
    description = "Deluge";
    extraGroups = ["media"];
    uid = 1002;
  };

  #users.users.jellyfin = {
  #  description = "JellyFin";
  #  extraGroups = ["media" "render" "video"];
  #};

  environment.systemPackages = with pkgs; [
    jellyfin-ffmpeg
  ];

  networking.firewall.allowedTCPPorts = [
    55686
  ];

  services.radarr = {
    enable = false;
  };

  services.jackett = {
    enable = false;
  };

  services.jellyfin = {
    enable = false;
    openFirewall = true;
  };

  services.jellyseerr = {
    enable = false;
    port = 5055;
    openFirewall = true;
  };

  services.sonarr = {
    enable = false;
    group = "media";
  };

  systemd.services.podman-deluge = {
    after = ["wg-quick-wg0.service"];
  };

  virtualisation.oci-containers.containers = {
    "deluge" = {
      image = "binhex/arch-delugevpn";
      autoStart = true;
      ports = ["8112:8112" "8118:8118" "58846:58846" "58946:58946"];

      volumes = [
        "/media:/media"
        "/home/alberand/.deluge:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];

      environment = {
        PUID = "0";
        PGID = "8096";
        VPN_ENABLED = "yes";
        VPN_CLIENT = "wireguard";
        VPN_PROV = "custom";
        STRICT_PORT_FORWARD = "yes";
        ENABLE_PRIVOXY = "yes";
        LAN_NETWORK = "192.168.0.100/32, 10.233.1.100/32";
        NAME_SERVERS = "84.200.69.80,37.235.1.174,1.1.1.1,37.235.1.177,84.200.70.40,1.0.0.1";
        DELUGE_DAEMON_LOG_LEVEL = "trace";
        DELUGE_WEB_LOG_LEVEL = "trace";
        DEBUG = "true";
        UMASK = "000";
        TZ = "Europe/London";
        DELUGE_ENABLE_WEBUI_PASSWORD = "no";
      };

      extraOptions = [
        "--privileged=true"
        ''--sysctl="net.ipv4.conf.all.src_valid_mark=1"''
        ''--sysctl="net.ipv4.ip_forward=1"''
      ];
    };
  };
}
