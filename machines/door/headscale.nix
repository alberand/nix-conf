{
  domain,
  public_ip,
}: {config, ...}: {
  age.secrets.cert = {
    file = ../../secrets/door-cert.age;
    mode = "640";
    owner = "caddy";
    group = "caddy";
  };
  age.secrets.key = {
    file = ../../secrets/door-key.age;
    mode = "640";
    owner = "caddy";
    group = "caddy";
  };

  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;
      settings = {
        logtail.enabled = false;
        server_url = "https://${domain}";
        dns.base_domain = "door.alberand.com";
        dns.nameservers.global = [
          "100.69.0.100"
          "194.242.2.2"
        ];
      };
    };

    caddy = {
      enable = true;

      virtualHosts = {
        "door.alberand.com".extraConfig = ''
          encode gzip
          reverse_proxy 127.0.0.1:${toString config.services.headscale.port}
          tls ${config.age.secrets.cert.path} ${config.age.secrets.key.path} {
            protocols tls1.3
          }
        '';
      };
    };
  };
}
