{
  domain,
  public_ip,
}: {config, ...}: {
  users.groups.headscale.members = [
    "caddy"
    "headscale"
  ];

  age.secrets.cert = {
    file = ../../secrets/door-cert.age;
    mode = "640";
    owner = "root";
    group = "headscale";
  };
  age.secrets.key = {
    file = ../../secrets/door-key.age;
    mode = "640";
    owner = "root";
    group = "headscale";
  };

  services = {
    headscale = {
      enable = false;
      address = "0.0.0.0";
      port = 8080;
      settings = {
        logtail.enabled = false;
        server_url = "https://${domain}";
        tls_key_path = config.age.secrets.key.path;
        tls_cert_path = config.age.secrets.cert.path;
        dns = {
          override_local_dns = true;
          base_domain = "door.alberand.com";
        };
        prefixes.v4 = "100.69.0.0/24";
      };
    };

    caddy = {
      enable = true;

      #virtualHosts = {
      #  "door.alberand.com".extraConfig = ''
      #    encode gzip
      #    reverse_proxy 127.0.0.1:${toString config.services.headscale.port}
      #    tls ${config.age.secrets.cert.path} ${config.age.secrets.key.path} {
      #      protocols tls1.3
      #    }
      #  '';
      #};
    };
  };
}
