{config, ...}: let
  uuid = 1911;
  port = 9000;
in {
  age.secrets.mealie.file = ../secrets/nixxy-mealie.age;

  users.users.mealie = {
    isNormalUser = true;
    description = "mealie user";
    uid = uuid;
    group = "mealie";
  };
  users.groups.mealie.gid = uuid;

  networking = {
    firewall.allowedTCPPorts = [
      port
    ];
  };

  systemd.tmpfiles.rules = [
    "d /media/var/lib/mealie 2755 mealie mealie -"
    "d /media/cstate/mealie/var/lib/mealie 2755 mealie mealie -"
  ];

  containers.food = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "cbr";
    hostAddress = "10.10.10.100";
    localAddress = "10.10.10.70/24";
    bindMounts = {
      "/var/lib" = {
        hostPath = "/media/cstate/mealie/var/lib";
        isReadOnly = false;
      };
      "/etc/mealie.env" = {
        hostPath = config.age.secrets.mealie.path;
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      services.mealie = {
        settings = {
          PUID = uuid;
          PGID = uuid;
          ALLOW_SIGNUP = "false";
          TZ = "UTC+2";
          DB_ENGINE = "sqlite";
        };
        inherit port;
        listenAddress = "0.0.0.0";
        enable = true;
        credentialsFile = "/etc/mealie.env";
      };

      system.stateVersion = "26.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [
            config.services.mealie.port
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
