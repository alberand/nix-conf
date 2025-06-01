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

  services.home-assistant.extraComponents = ["jellyfin"];

  # Media group to access media storage
  users.groups.media = {
    name = "media";
    gid = 8096;
    members = [config.user "jellyfin" "sonarr" "radarr" "jackett"];
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

  environment.systemPackages = with pkgs; [jellyfin-ffmpeg];

  networking.firewall.allowedTCPPorts = [55686];

  services.radarr = {
    enable = true;
  };

  services.jackett = {
    enable = true;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.jellyseerr = {
    enable = true;
    port = 5055;
    openFirewall = true;
  };

  services.sonarr = {
    enable = true;
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
        LAN_NETWORK = "192.168.0.100/32";
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
