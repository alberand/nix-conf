{config, pkgs,...}: {
  age.secrets.pocket-id-env = {
    file = ../../secrets/door-pocket-id-env.age;
    mode = "440";
    owner = "pocket-id";
    group = "pocket-id";
  };

  age.secrets.pocket-id-cert = {
    file = ../../secrets/door-pocket-id-cert.age;
    name = "cert.cem";
    mode = "660";
    owner = "caddy";
    group = "caddy";
  };

  age.secrets.pocket-id-key = {
    file = ../../secrets/door-pocket-id-key.age;
    name = "key.cem";
    mode = "640";
    owner = "caddy";
    group = "caddy";
  };

  environment.systemPackages = [
    pkgs.nss
  ];

  services = {
    caddy = {
      enable = true;

      virtualHosts = let
        cert = config.age.secrets.pocket-id-cert.path;
        key = config.age.secrets.pocket-id-key.path;
      in {
        "login.alberand.com".extraConfig = ''
          encode gzip
          reverse_proxy 127.0.0.1:${builtins.toString config.services.pocket-id.settings.PORT}
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';
      };
    };

    pocket-id = {
      enable = true;
      settings = {
        APP_URL = "https://login.alberand.com";
        TRUST_PROXY = true;
        PORT = 3000;
      };
      environmentFile = config.age.secrets.pocket-id-env.path;
    };
};
}
