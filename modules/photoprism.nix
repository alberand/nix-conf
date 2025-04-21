{
  config,
  pkgs,
  lib,
  ...
}: {
  users.users = {
    photoprism = {
      name = "photoprism";
      group = "photoprism";
      isNormalUser = true;
      uid = 1110;
      extraGroups = ["media"];
    };
  };

  users.groups.photoprism = {
    name = "photoprism";
    members = ["photoprism"];
    gid = 1110;
  };

  services.photoprism = {
    enable = true;
    address = "localhost";
    port = 8113;
    originalsPath = "/media/photos";
    settings = {
      PHOTOPRISM_ADMIN_USER = "alberand";
      PHOTOPRISM_ADMIN_PASSWORD = "123456";
    };
  };

  systemd.services.photoprism = {
    serviceConfig = {DynamicUser = lib.mkForce false;};
  };

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

  # TODO copy & remove
  #fileSystems."/media/photos/julia" = {
  #device = "/media/stuff/BUP/Pictures/jpg";
  #options = [ "bind" ];
  #};
}
