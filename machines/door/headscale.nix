{
  domain,
  public_ip,
  door_ip,
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

  networking.firewall = {
    enable = true;
    interfaces.ens3 = {
      allowedTCPPorts = [
        # id.alberand.com
        80
        443
      ];
      allowedUDPPorts = [
        443
        3478
        41641
      ];
    };
  };

  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;
      settings = {
        log.level = "debug";
        logtail.enabled = false;
        server_url = "https://${domain}";
        metrics_listen_addr = "0.0.0.0:9090";
        dns = {
          override_local_dns = true;
          magic_dns = true;
          base_domain = "dns.alberand.com";
          nameservers = {
            global = [
              "${door_ip}"
            ];
            search_domains = [
              "~alberand.com"
            ];
          };
        };
        prefixes = {
          v4 = "100.69.0.0/24";
          v6 = "fd7a:115c:a1e0::/48";
        };

        oidc = {
          scope = ["openid" "profile" "email" "groups"];
          issuer = "https://id.alberand.com";
          client_secret_path = config.age.secrets.headscale-pocket-id.path;
          client_id = "24c49914-ceb8-47ff-ac23-178632f6d399";
          allowed_users = [
            "alberand"
            "andrey.albershteyn@gmail.com"
            "julia"
            "iuliia.albershtein@gmail.com"
            "misha"
            "warindeon@gmail.com"
          ];
          pkce = {
            enabled = true;
          };
          only_start_if_oidc_is_available = true;
        };

        derp = {
          server = {
            enabled = false;
            region_id = 999;
            region_code = "door";
            region_name = "Headscale Embedded DERP";
            stun_listen_addr = "${public_ip}:3478";
            auto_update_enabled = true;
            automatically_add_embedded_derp_region = true;
          };
        };
      };
    };

    caddy = {
      enable = true;

      virtualHosts = let
        cert = "/var/lib/acme/alberand.com/cert.pem";
        key = "/var/lib/acme/alberand.com/key.pem";
      in {
        "door.alberand.com".extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.headscale.port}
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';
      };
    };
  };
}
