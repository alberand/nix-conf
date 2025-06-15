{...}: {
  containers.photos = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "cbr";
    hostAddress = "10.10.10.100";
    localAddress = "10.10.10.80/24";
    bindMounts = {
      "/media/photos" = {
        hostPath = "/media/photos";
        isReadOnly = false;
      };
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
      users.users.photoprism = {
        isNormalUser = true;
        uid = 3000;
        group = "photoprism";
      };

      users.groups.photoprism = {
        gid = 3000;
      };

      services.photoprism = {
        enable = true;
        address = "10.10.10.80";
        port = 8113;
        originalsPath = "/media/photos";
        settings = {
          PHOTOPRISM_HTTP_HOSTNAME = "photos.alberand.com";
          PHOTOPRISM_ADMIN_USER = "alberand";
          PHOTOPRISM_ADMIN_PASSWORD = "123456";
          PHOTOPRISM_DATABASE_DRIVER = "sqlite";

          PHOTOPRISM_UID = toString config.users.users.photoprism.uid;
          PHOTOPRISM_GID = toString config.users.groups.photoprism.gid;
        };
      };

      # Some hacks to make photoprism scan /photos daily
      systemd = {
        timers = {
          "photoprism-index" = {
            wantedBy = ["timers.target"];
            timerConfig = {
              OnCalendar = "daily";
              Unit = "photoprism-index.service";
              Persistent = true;
            };
          };
        };
      };

      systemd.services = {
        "photoprism-index" = {
          serviceConfig = {
            Type = "oneshot";
            User = "photoprism";
            Group = "photoprism";
            DynamicUser = false;
            inherit
              (config.systemd.services.photoprism.serviceConfig)
              StateDirectory
              WorkingDirectory
              RuntimeDirectory
              ReadWritePaths
              ;
          };
          environment = config.systemd.services.photoprism.environment;
          script = ''
            set -eux
            ${pkgs.photoprism}/bin/photoprism index
          '';
        };
      };

      system.stateVersion = "25.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [
            8113
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
