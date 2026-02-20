{config, ...}: {
  age.secrets.miniflux-id = {
    file = ../secrets/miniflux-id.age;
    mode = "400";
    owner = "miniflux";
    group = "miniflux";
  };

  age.secrets.miniflux-secret = {
    file = ../secrets/miniflux-secret.age;
    mode = "400";
    owner = "miniflux";
    group = "miniflux";
  };

  users.users.miniflux = {
    isNormalUser = true;
    description = "Miniflux user";
    group = "miniflux";
    uid = 9191;
  };

  users.groups.miniflux = {
    name = "miniflux";
    gid = 9191;
  };

  services.miniflux = {
    enable = true;
    config = {
      BASE_URL = "https://miniflux.alberand.com";
      LISTEN_ADDR = "127.0.0.1:9191";
      CREATE_ADMIN = false;

      OAUTH2_CLIENT_ID_FILE = config.age.secrets.miniflux-id.path;
      OAUTH2_CLIENT_SECRET_FILE = config.age.secrets.miniflux-secret.path;
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://id.alberand.com";
      OAUTH2_OIDC_PROVIDER_NAME = "Pocket ID";
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_REDIRECT_URL = "https://miniflux.alberand.com/oauth2/oidc/callback";
      OAUTH2_USER_CREATION = 1;
    };
  };
}
