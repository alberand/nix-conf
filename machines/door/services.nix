{config, ...}: {
  services = {
    caddy = {
      enable = true;

      virtualHosts = let
        cert = config.age.secrets.acme-cert.path;
        key = config.age.secrets.acme-key.path;
      in {
        "jellyfin.alberand.com".extraConfig = ''
          encode gzip
          reverse_proxy 100.69.0.100:55686
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';
      };
    };
  };
}
