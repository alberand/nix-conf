{config, ...}: let
  uuid = 8080;
  port = 8080;
in {
  users.users.stirling-pdf = {
    isNormalUser = true;
    uid = uuid;
    group = "stirling-pdf";
  };

  users.groups.stirling-pdf = {
    gid = uuid;
  };

  networking = {
    firewall.allowedTCPPorts = [
      port
    ];
  };

  systemd.tmpfiles.rules = [
    "d /media/cstate/stirling-pdf/var/lib/stirling-pdf 0755 stirling-pdf stirling-pdf - -"
    "A /media/cstate/stirling-pdf/var/lib/stirling-pdf - - - - m::rwx"
    "A+ /media/cstate/stirling-pdf/var/lib/stirling-pdf - - - - u:stirling-pdf:rwx"
    "A+ /media/cstate/stirling-pdf/var/lib/stirling-pdf - - - - u:${config.user}:rwx"
  ];

  containers.stirling-pdf = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "cbr";
    hostAddress = "10.10.10.100";
    localAddress = "10.10.10.81/24";
    bindMounts = {
      "/var/lib" = {
        hostPath = "/media/cstate/stirling-pdf/var/lib";
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      users.users.stirling-pdf = {
        isNormalUser = true;
        uid = uuid;
        group = "stirling-pdf";
      };

      users.groups.stirling-pdf = {
        gid = uuid;
      };

      services.stirling-pdf = {
        enable = true;
        environment = {
          INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
          SERVER_PORT = 8080;
          UI_APPNAME = "PDF";
        };
      };

      system.stateVersion = "25.05";

      networking = {
        firewall = {
          enable = true;
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
}
