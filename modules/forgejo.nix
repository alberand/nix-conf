{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
in {
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
    stateDir = "/media/forgejo";
    database = {
      type = "mysql";
      user = "forgejo";
      socket = "/run/mysqld/mysqld.sock";
      host = "127.0.0.1";
      createDatabase = true;
    };

    # Enable support for Git Large File Storage
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = "git.alberand.com";
        # You need to specify this to remove the port from URLs in the web UI.
        ROOT_URL = "https://${srv.DOMAIN}/";
        HTTP_PORT = 3000;
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
}
