{config, ...}: let
  uuid = 3110;
  port = 3110;
in {
  users.users.gatus = {
    isNormalUser = true;
    uid = uuid;
    group = "gatus";
  };

  users.groups.gatus = {
    gid = uuid;
  };

  age.secrets.gatus = {
    file = ../secrets/gatus.age;
    owner = "gatus";
  };

  networking = {
    firewall.allowedTCPPorts = [
      port
    ];
  };

  containers.gatus = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "cbr";
    hostAddress = "10.10.10.100";
    localAddress = "10.10.10.90/24";
    bindMounts."${config.age.secrets.gatus.path}".isReadOnly = true;
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      users.users.gatus = {
        isNormalUser = true;
        uid = uuid;
        group = "gatus";
      };

      users.groups.gatus = {
        gid = uuid;
      };

      services.gatus = {
        enable = true;
        openFirewall = true;
        environmentFile = "/run/agenix/gatus";
        settings = {
          web.port = port;
          storage = {
            type = "sqlite";
            path = "/var/lib/gatus/data.db";
          };
          ui = {
            title = "homelab status";
            dark-mode = true;
          };
          alerting.telegram = {
            token = "\${GATUS_TELEGRAM_TOKEN}";
            id = "\${GATUS_TELEGRAM_USER}";
          };
          endpoints = [
            {
              name = "Jellyfin";
              url = "https://jellyfin.alberand.com/health";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[BODY] == Healthy"
                "[RESPONSE_TIME] < 300"
              ];
              alerts = [
                {
                  enabled = true;
                  type = "telegram";
                  failure-threshold = 2;
                  success-threshold = 1;
                  description = "Jellyfin is down!";
                  send-on-resolved = true;
                }
              ];
            }
            {
              name = "Forgejo";
              url = "https://git.alberand.com/api/healthz";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[BODY].status == pass"
                "[RESPONSE_TIME] < 300"
              ];
              alerts = [
                {
                  enabled = true;
                  type = "telegram";
                  failure-threshold = 2;
                  success-threshold = 1;
                  description = "Forgejo is down!";
                  send-on-resolved = true;
                }
              ];
            }
            {
              name = "Photoprism";
              url = "https://photos.alberand.com/library/browse";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 300"
              ];
              alerts = [
                {
                  enabled = true;
                  type = "telegram";
                  failure-threshold = 2;
                  success-threshold = 1;
                  description = "Photoprism is down!";
                  send-on-resolved = true;
                }
              ];
            }
            {
              name = "Jellyseerr";
              url = "https://jellyseerr.alberand.com/api/v1/status";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 300"
              ];
              alerts = [
                {
                  enabled = true;
                  type = "telegram";
                  failure-threshold = 2;
                  success-threshold = 1;
                  description = "Jellyseerr is down!";
                  send-on-resolved = true;
                }
              ];
            }
            {
              name = "Mealie";
              url = "https://food.alberand.com/";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 300"
              ];
              alerts = [
                {
                  enabled = true;
                  type = "telegram";
                  failure-threshold = 2;
                  success-threshold = 1;
                  description = "Tandoor is down!";
                  send-on-resolved = true;
                }
              ];
            }
            {
              name = "Nextcloud";
              url = "https://files.alberand.com/apps/theming/favicon/files?v=bcd3195f";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 500"
              ];
              alerts = [
                {
                  enabled = true;
                  type = "telegram";
                  failure-threshold = 2;
                  success-threshold = 1;
                  description = "Nextcloud is down!";
                  send-on-resolved = true;
                }
              ];
            }
            {
              name = "DNS";
              url = "100.69.0.4";
              interval = "5m";
              dns = {
                query-name = "home.alberand.com";
                query-type = "A";
              };
              conditions = [
                "[BODY] == 100.69.0.4"
                "[DNS_RCODE] == NOERROR"
              ];
              alerts = [
                {
                  enabled = true;
                  type = "telegram";
                  failure-threshold = 2;
                  success-threshold = 1;
                  description = "DNS is down!";
                  send-on-resolved = true;
                }
              ];
            }
            {
              name = "Jackett";
              url = "http://10.10.10.30:9117/favicon.ico";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[CONNECTED] == true"
                "[RESPONSE_TIME] < 300"
              ];
              alerts = [
                {
                  enabled = true;
                  type = "telegram";
                  failure-threshold = 2;
                  success-threshold = 1;
                  description = "Jackett is down!";
                  send-on-resolved = true;
                }
              ];
            }
            {
              name = "Radarr";
              url = "http://10.10.10.30:7878";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 300"
              ];
              alerts = [
                {
                  enabled = true;
                  type = "telegram";
                  failure-threshold = 2;
                  success-threshold = 1;
                  description = "Radarr is down!";
                  send-on-resolved = true;
                }
              ];
            }
            {
              name = "Sonarr";
              url = "http://10.10.10.30:8989";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 300"
              ];
              alerts = [
                {
                  enabled = true;
                  type = "telegram";
                  failure-threshold = 2;
                  success-threshold = 1;
                  description = "Sonarr is down!";
                  send-on-resolved = true;
                }
              ];
            }
            {
              name = "Deluge";
              url = "http://10.10.10.50:8112";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 300"
              ];
              alerts = [
                {
                  enabled = true;
                  type = "telegram";
                  failure-threshold = 2;
                  success-threshold = 1;
                  description = "Deluge is down!";
                  send-on-resolved = true;
                }
              ];
            }
          ];
        };
      };

      system.stateVersion = "25.11";

      networking = {
        nameservers = ["100.69.0.4"];
        firewall = {
          enable = true;
          allowedTCPPorts = [
            port
          ];
        };
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;
    };
  };
}
