{config, ...}: {
  age.secrets.nextcloud.file = ../secrets/nextcloud.age;

  networking = {
    firewall.allowedTCPPorts = [
      55686
    ];
    nftables = {
      enable = true;

      tables.services = {
        enable = true;
        family = "ip";
        content = ''
          chain PREROUTING {
            type nat hook prerouting priority dstnat; policy accept;
            iifname "tailscale0" tcp dport 7000 dnat to 10.10.10.60
          }
        '';
      };
    };
  };

  containers.nextcloud = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "cbr";
    hostAddress = "10.10.10.100";
    localAddress = "10.10.10.60/24";
    bindMounts = {
      "/media/nextcloud" = {
        hostPath = "/media/nextcloud";
        isReadOnly = false;
      };
      "/etc/password" = {
        hostPath = config.age.secrets.nextcloud.path;
        isReadOnly = false;
      };
      "/var/lib/nextcloud" = {
        hostPath = "/media/var/lib/nextcloud";
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      services.nextcloud = {
        enable = true;
        hostName = "files.alberand.com";
        home = "/var/lib/nextcloud";
        datadir = "/media/nextcloud";
        maxUploadSize = "20G";
        https = true;
        database.createLocally = true;
        configureRedis = true;
        config = {
          adminuser = "alberand";
          adminpassFile = "/etc/password";
          dbtype = "sqlite";
        };
        settings = {
          log_type = "file";
          trusted_proxies = [
            "100.69.0.100"
          ];
        };
      };

      system.stateVersion = "25.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [
            80
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
