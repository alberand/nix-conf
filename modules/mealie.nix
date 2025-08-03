{...}: let
  uuid = 1911;
  port = 9000;
in {
  age.secrets.mealie.file = ../../secrets/nixxy-mealie.age;

  users.users.mealie = {
    isNormalUser = true;
    description = "mealie user";
    uid = uuid;
    group = "mealie";
    # home = "/media/var/lib/forgejo";
  };
  users.groups.mealie.gid = uuid;

  networking = {
    firewall.allowedTCPPorts = [
      port
    ];
  };

  systemd.tmpfiles.rules = [
    # Ensure forgejo configuration dir exists
    "d /media/var/lib/mealie 0755 mealie mealie - -"
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
        credentialsFile = config.age.secrets.mealie.path;
      };

      system.stateVersion = "25.05";

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
