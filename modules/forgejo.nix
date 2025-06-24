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
            iifname "tailscale0" tcp dport 2222 dnat to 10.10.10.40:2222
          }
          chain POSTROUTING {
            type nat hook postrouting priority srcnat; policy accept;
            ip daddr 10.10.10.40 tcp dport 2222 masquerade
          }
        }
      '';
    };
  };

  #services.openssh = {
  #  hostKeys = [
  #    {
  #      bits = 4096;
  #      path = "/etc/ssh/ssh_host_rsa_key";
  #      type = "rsa";
  #    }
  #    {
  #      path = "/etc/ssh/ssh_host_ed25519_key";
  #      type = "ed25519";
  #    }
  #    {
  #      path = "/media/var/lib/forgejo/data/ssh/gitea.rsa";
  #      type = "rsa";
  #    }
  #  ];
  #  extraConfig = ''
  #    # Route forgejo user to container
  #    Match User forgejo
  #        ForceCommand ssh -T -o StrictHostKeyChecking=no -p 2222 forgejo@10.10.10.40 "$SSH_ORIGINAL_COMMAND"
  #        PermitTTY no
  #        X11Forwarding no
  #        AllowAgentForwarding no
  #        AllowUsers forgejo
  #        AuthenticationMethods publickey
  #  '';
  #};

  #users.users.forgejo = {
  #  isNormalUser = true;
  #  description = "forgejo SSH user";
  #  uid = 2222;
  #  home = "/media/var/lib/forgejo";
  #};
  #users.groups.forgejo.gid = 2222;

  containers.forgejo = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "cbr";
    hostAddress = "10.10.10.100";
    localAddress = "10.10.10.40/24";
    forwardPorts = [
      {
        containerPort = 2222;
        hostPort = 2222;
        protocol = "tcp";
      }
    ];
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

      users.users.forgejo = {
        description = "forgejo SSH user";
        uid = 2222;
      };
      users.groups.forgejo.gid = 2222;

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
