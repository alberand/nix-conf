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
  age.secrets.headscale-pocket-id = {
    file = ../../secrets/door-headscale-pocket-id.age;
    mode = "400";
    owner = "headscale";
    group = "headscale";
  };

  services = {
    headscale = {
      enable = true;
      address = "127.0.0.1";
      port = 8080;
      settings = {
        log.level = "debug";
        logtail.enabled = false;
        server_url = "http://${domain}";
        metrics_listen_addr = "127.0.0.1:9090";
        dns = {
          override_local_dns = true;
          magic_dns = true;
          base_domain = "door.alberand.com";
          nameservers.global = [
            "194.242.2.9" # Mullvad
          ];
        };
        prefixes.v4 = "100.69.0.0/24";

        oidc = {
          scope = ["openid" "profile" "email" "groups"];
          issuer = "https://login.alberand.com";
          client_secret_path = config.age.secrets.headscale-pocket-id.path;
          client_id = "24c49914-ceb8-47ff-ac23-178632f6d399";
          allowed_users = [
            "alberand"
            "andrey.albershteyn@gmail.com"
          ];
        };
      };
    };

    caddy = {
      enable = true;

      virtualHosts = {
        "door.alberand.com".extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.headscale.port}
          tls ${config.age.secrets.cert.path} ${config.age.secrets.key.path} {
            protocols tls1.3
          }
        '';
      };
    };
  };
}
