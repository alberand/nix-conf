{
  pkgs,
  config,
  ...
}: {
  age.secrets.acme-env.file = ../secrets/acme-env.age;

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

  networking.firewall = {
    enable = true;
    interfaces.headscale = {
      allowedTCPPorts = [
        80
        443
      ];
    };
  };

  services.caddy = {
    enable = true;

    virtualHosts = let
      cert = "/var/lib/acme/alberand.com/cert.pem";
      key = "/var/lib/acme/alberand.com/key.pem";
      dashboard = pkgs.callPackage (import ../configs/dashboard/derivation.nix) {};
    in {
      "home.alberand.com".extraConfig = ''
        encode gzip
        root * ${dashboard}/dashboard/
        file_server
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "photos.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.11:2283
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "food.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.70:9000
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "git.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.40:3000
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "jellyseerr.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.30:5055
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "files.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.60
        redir /.well-known/carddav /remote.php/dav/ 301
        redir /.well-known/caldav /remote.php/dav/ 301
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "status.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.90:3110
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "pdf.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.81:8080
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "reddit.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:9001
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "copyparty.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:3210
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "deluge.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.50:8112
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "radarr.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.30:7878
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "sonarr.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.30:8989
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "jackett.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.30:9117
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';

      "lidarr.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.30:8686
        tls ${cert} ${key} {
          protocols tls1.3
        }
      '';
    };
  };
}
