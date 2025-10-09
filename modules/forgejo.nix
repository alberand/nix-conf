{config, ...}: let
  cfg = config.services.forgejo;
  uuid = 3200;
  port = 3000;
in {
  networking = {
    # SSH port on container
    firewall.allowedTCPPorts = [
      22
    ];
  };

  users.users.forgejo = {
    isNormalUser = true;
    description = "forgejo user";
    uid = uuid;
    group = "forgejo";
    openssh.authorizedKeys.keyFiles = [
      ../secrets/nixxy_ed25519.pub
      ../secrets/thinky_ed25519.pub
    ];
  };
  users.groups.forgejo.gid = uuid;

  systemd.tmpfiles.rules = [
    # Ensure forgejo configuration dir exists
    "d /media/cstate/forgejo/var/lib/forgejo 0755 forgejo forgejo - -"
    # Ensure forgejo repositories and lsf directories exists
    "d /media/forgejo 0755 forgejo forgejo - -"
    "d /media/forgejo/repositories 0755 forgejo forgejo - -"
    "d /media/forgejo/lsf 0755 forgejo forgejo - -"
    # Set a mask to allow main system user to have full permission
    "A /media/forgejo - - - - m::rwx"
    # Grant forgejo user/group to read/write git storage
    "A+ /media/forgejo - - - - u:forgejo:rwx,g:forgejo:rwx"
    # Grant main system user permission to read/write git storage
    "A+ /media/forgejo - - - - u:${config.user}:rwx"
  ];

  services.openssh = {
    hostKeys = [
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/media/cstate/forgejo/var/lib/forgejo/data/ssh/gitea.rsa";
        type = "rsa";
      }
    ];
    extraConfig = ''
      # Route forgejo user to container
      Match User forgejo
          ForceCommand ssh -T -o StrictHostKeyChecking=no -p 2222 forgejo@10.10.10.40 "\$SSH_ORIGINAL_COMMAND"
          # AuthorizedKeysCommand forgejo-cli --config /var/lib/forgejo/custom/conf/app.ini keys -e git -u %u -t %t -k %k
          PermitTTY no
          X11Forwarding no
          AllowAgentForwarding yes
          AllowUsers forgejo
          AuthenticationMethods publickey
    '';
  };

  containers.forgejo = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "cbr";
    hostAddress = "10.10.10.100";
    localAddress = "10.10.10.40/24";
    bindMounts = {
      "/media/forgejo" = {
        hostPath = "/media/forgejo";
        isReadOnly = false;
      };
      "/var/lib/forgejo" = {
        hostPath = "/media/cstate/forgejo/var/lib/forgejo";
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = let
        forgejo-cli = pkgs.writeScriptBin "forgejo-cli" ''
          #!${pkgs.runtimeShell}
          cd ${cfg.stateDir}
          sudo=exec
          if [[ "$USER" != forgejo ]]; then
            sudo='exec /run/wrappers/bin/sudo -u ${cfg.user} -g ${cfg.group} --preserve-env=GITEA_WORK_DIR --preserve-env=GITEA_CUSTOM'
          fi
          # Note that these variable names will change
          export GITEA_WORK_DIR=${cfg.stateDir}
          export GITEA_CUSTOM=${cfg.customDir}
          $sudo ${lib.getExe cfg.package} "$@"
        '';
      in [
        forgejo-cli
      ];

      users.users.forgejo = {
        description = "forgejo SSH user";
        uid = uuid;
      };
      users.groups.forgejo.gid = uuid;

      services.forgejo = {
        enable = true;
        database = {
          type = "sqlite3";
          user = "forgejo";
          createDatabase = true;
        };

        repositoryRoot = "/media/forgejo/repositories";

        # Enable support for Git Large File Storage
        lfs = {
          enable = true;
          contentDir = "/media/forgejo/lfs";
        };
        settings = {
          server = {
            DOMAIN = "git.alberand.com";
            LANDING_PAGE = "login";
            # You need to specify this to remove the port from URLs in the web UI.
            ROOT_URL = "https://git.alberand.com/";
            HTTP_ADDR = "10.10.10.40";
            HTTP_PORT = port;

            DISABLE_SSH = false;
            START_SSH_SERVER = true;
            SSH_LISTEN_PORT = 2222;
            SSH_LISTEN_HOST = "0.0.0.0";
            SSH_DOMAIN = "git.alberand.com";
          };
          # You can temporarily allow registration to create an admin user.
          service.DISABLE_REGISTRATION = false;
          # Add support for actions, based on act: https://github.com/nektos/act
          actions = {
            ENABLED = true;
            DEFAULT_ACTIONS_URL = "github";
          };

          "git.timeout" = {
            MIGRATE = 3600; # 1 hour for huge repos
          };

          indexer = {
            REPO_INDEXER_ENABLED = true;
          };
        };
      };

      system.stateVersion = "25.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [
            port
            2222
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
