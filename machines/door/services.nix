{callPackage}: {config, ...}: {
  age.secrets.acme-env.file = ../../secrets/acme-env.age;

  networking.firewall = {
    enable = true;
    interfaces.headscale = {
      allowedTCPPorts = [
        80
        443
      ];
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "andrey.albershteyn@gmail.com";
    defaults.enableDebugLogs = true;
    # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

    certs = {
      "alberand.com" = {
        group = config.services.caddy.group;

        domain = "alberand.com";
        extraDomainNames = ["*.alberand.com"];

        dnsProvider = "wedos";
        dnsResolver = "ns.wedos.net:53";
        dnsPropagationCheck = true;
        enableDebugLogs = true;
        environmentFile = config.age.secrets.acme-env.path;
      };
    };
  };

  services = {
    caddy = {
      enable = true;

      virtualHosts = let
        cert = "/var/lib/acme/alberand.com/cert.pem";
        key = "/var/lib/acme/alberand.com/key.pem";
        server_ip = "100.69.0.2";
      in {
        "alberand.com".extraConfig = ''
          encode gzip
          root * /var/www/blog
          file_server
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';

        "jellyfin.alberand.com".extraConfig = ''
          encode gzip
          reverse_proxy ${server_ip}:55686
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';
      };
    };
  };

  systemd.tmpfiles.rules = [
    # Ensure alberand.com dir exists
    "d /var/www 0755 caddy caddy - -"
    # Set a mask to allow main system user to have full permission
    "A /var/www - - - - m::rwx"
    # Grant main system user permission to read/write git storage
    "A+ /var/www - - - - u:alberand:rwx"
  ];
}
