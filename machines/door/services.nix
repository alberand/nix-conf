{callPackage}: {config, ...}: {
  age.secrets.acme-env.file = ../../secrets/acme-env.age;

  security.acme = {
    acceptTerms = true;
    defaults.email = "andrey.albershteyn@gmail.com";
    defaults.enableDebugLogs = true;
    # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

    certs = {
      "alberand.com" = {
        group = config.services.caddy.group;

        domain = "alberand.com";
        extraDomainNames = [ "*.alberand.com" ];

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
        dashboard = callPackage (import ../../configs/dashboard/derivation.nix) {};
        server_ip = "100.69.0.2";
        vps_ip = "100.69.0.4";
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

        "home.alberand.com".extraConfig = ''
          bind ${vps_ip}
          encode gzip
          root * ${dashboard}/dashboard/
          file_server
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';

        "photos.alberand.com".extraConfig = ''
          bind ${vps_ip}
          encode gzip
          reverse_proxy ${server_ip}:8113
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';

        "food.alberand.com".extraConfig = ''
          bind ${vps_ip}
          encode gzip
          reverse_proxy ${server_ip}:9000
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';

        "git.alberand.com".extraConfig = ''
          bind ${vps_ip}
          encode gzip
          reverse_proxy ${server_ip}:3000
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';

        "jellyseerr.alberand.com".extraConfig = ''
          bind ${vps_ip}
          encode gzip
          reverse_proxy ${server_ip}:5055
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';

        "files.alberand.com".extraConfig = ''
          bind ${vps_ip}
          encode gzip
          reverse_proxy ${server_ip}:7000
          redir /.well-known/carddav /remote.php/dav/ 301
          redir /.well-known/caldav /remote.php/dav/ 301
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';

        "health.alberand.com".extraConfig = ''
          bind ${vps_ip}
          encode gzip
          reverse_proxy ${server_ip}:3110
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';

        "pdf.alberand.com".extraConfig = ''
          bind ${vps_ip}
          encode gzip
          reverse_proxy ${server_ip}:8080
          tls ${cert} ${key} {
            protocols tls1.3
          }
        '';

        "status.alberand.com".extraConfig = ''
          bind ${vps_ip}
          encode gzip
          reverse_proxy ${server_ip}:3110
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
