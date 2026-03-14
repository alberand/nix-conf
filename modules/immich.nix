{config, ...}: let
  uuid = 2283;
  port = uuid;
in {
  users.users.immich = {
    isNormalUser = true;
    uid = uuid;
    group = "immich";
  };

  users.groups.immich = {
    gid = uuid;
  };

  networking = {
    firewall.allowedTCPPorts = [
      port
    ];
  };

  systemd.tmpfiles.rules = [
    "d /media/cstate/immich/var/lib 2755 immich immich -"
    "d /media/photos/immich 2755 immich immich -"
  ];

  containers.immich = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "cbr";
    hostAddress = "10.10.10.100";
    localAddress = "10.10.10.11/24";
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
      # Sharing GPU for video transcoding
      "/dev/dri" = {
        hostPath = "/dev/dri";
        isReadOnly = false;
      };
      "/media/photos" = {
        hostPath = "/media/photos";
        isReadOnly = false;
      };
      "/var/lib" = {
        hostPath = "/media/cstate/immich/var/lib";
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

      users.users.immich = {
        uid = uuid;
      };

      users.groups.immich = {
        gid = uuid;
      };

      services.immich = {
        enable = true;
        host = "0.0.0.0";
        openFirewall = true;
        port = port;
        mediaLocation = "/media/photos/immich";
        accelerationDevices = [
          "/dev/dri/renderD128"
        ];
        settings = {
          server.externalDomain = "https://photos.alberand.com";
          newVersionCheck.enabled = false;
        };
        environment = {
          IMMICH_LOG_LEVEL = "verbose";
        };
      };

      system.stateVersion = "25.11";

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
