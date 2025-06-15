{config, ...}: let
  cfg = config.services.forgejo;
in {
  networking = {
    # SSH port on container
    firewall.allowedTCPPorts = [
      2222
    ];
    nftables = {
      enable = true;
      ruleset = ''
        table ip nat {
          chain PREROUTING {
            type nat hook prerouting priority dstnat; policy accept;
            iifname "tailscale0" tcp dport 2222 dnat to 10.10.10.40
          }
          chain POSTROUTING {
            type nat hook postrouting priority srcnat; policy accept;
            ip saddr 10.10.10.40 snat to 100.69.0.100
          }
        }
      '';
    };
  };

  containers.forgejo = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "cbr";
    hostAddress = "10.10.10.100";
    localAddress = "10.10.10.40/24";
    bindMounts = {
      "/media" = {
        hostPath = "/media";
        isReadOnly = false;
      };
      "/var/lib/forgejo" = {
        hostPath = "/media/var/lib/forgejo";
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

      services.forgejo = {
        enable = true;
        database = {
          type = "sqlite3";
          user = "forgejo";
          createDatabase = true;
        };

        # Enable support for Git Large File Storage
        lfs.enable = true;
        settings = {
          server = {
            DOMAIN = "git.alberand.com";
            # You need to specify this to remove the port from URLs in the web UI.
            ROOT_URL = "https://git.alberand.com/";
            HTTP_ADDR = "10.10.10.40";
            HTTP_PORT = 3000;

            DISABLE_SSH = false;
            START_SSH_SERVER = true;
            SSH_PORT = 2222;
            SSH_LISTEN_HOST = "0.0.0.0";
            SSH_DOMAIN="https://git.alberand.com/";
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
            3000
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
