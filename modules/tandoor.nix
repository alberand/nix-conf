{...}: {
  containers.food = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "cbr";
    hostAddress = "10.10.10.100";
    localAddress = "10.10.10.70/24";
    bindMounts = {
      "/var/lib/tandoor-recipes" = {
        hostPath = "/media/var/lib/tandoor-recipes";
        isReadOnly = false;
      };
    };
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      services.tandoor-recipes = {
        enable = true;
        address = "10.10.10.70";
        port = 8114;
        extraConfig = {
          ALLOWED_HOSTS = "food.alberand.com";
          DB_ENGINE = "django.db.backends.sqlite3";
          GUNICORN_MEDIA = "1";
        };
      };

      system.stateVersion = "25.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [
            8114
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
