{
  pkgs,
  config,
  ...
}: {
  age.secrets.acme-env.file = ../secrets/acme-env.age;

  security.acme = let
    certfor = {name}: {
      group = config.services.caddy.group;

      domain = "${name}.alberand.com";
      dnsProvider = "wedos";
      dnsResolver = "ns.wedos.net:53";
      dnsPropagationCheck = true;
      enableDebugLogs = true;
      environmentFile = config.age.secrets.acme-env.path;
    };
  in {
    acceptTerms = true;
    defaults.email = "andrey.albershteyn@gmail.com";
    defaults.enableDebugLogs = true;
    #defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

    certs = {
      "home.alberand.com" = certfor { name = "home"; };
      "git.alberand.com" = certfor { name = "git"; };
      "food.alberand.com" = certfor { name = "food"; };
      "photos.alberand.com" = certfor { name = "photos"; };
      "jellyseerr.alberand.com" = certfor { name = "jellyseerr"; };
      "files.alberand.com" = certfor { name = "files"; };
      "health.alberand.com" = certfor { name = "health"; };
      "door.alberand.com" = certfor { name = "door"; };
      "login.alberand.com" = certfor { name = "login"; };
    };

    certs."whereisiss.com" = {
      group = config.services.caddy.group;

      domain = "whereisiss.com";
      extraDomainNames = [
        "food.whereisiss.com"
        "movies.whereisiss.com"
        "photos.whereisiss.com"
        "git.whereisiss.com"
      ];
      dnsProvider = "wedos";
      dnsResolver = "ns.wedos.net:53";
      dnsPropagationCheck = true;
      enableDebugLogs = true;
      environmentFile = config.age.secrets.acme-env.path;
    };
  };

  services.caddy = {
    enable = true;

    virtualHosts = let
      dashboard = pkgs.callPackage (import ../configs/dashboard/derivation.nix) {};
      certlocname = {name}: "/var/lib/acme/${name}.alberand.com";
    in {
      "home.alberand.com".extraConfig = ''
        encode gzip
        root * ${dashboard}/dashboard/
        file_server
        tls ${certlocname {name = "home";}}/cert.pem ${certlocname {name = "home";}}/key.pem {
          protocols tls1.3
        }
      '';
      "photos.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.80:8113
        tls ${certlocname {name = "photos";}}/cert.pem ${certlocname {name = "photos";}}/key.pem {
          protocols tls1.3
        }
      '';
      "food.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.70:9000
        tls ${certlocname {name = "food";}}/cert.pem ${certlocname {name = "food";}}/key.pem {
          protocols tls1.3
        }
      '';
      "git.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.40:3000
        tls ${certlocname {name = "git";}}/cert.pem ${certlocname {name = "git";}}/key.pem {
          protocols tls1.3
        }
      '';
      "jellyseerr.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.30:5055
        tls ${certlocname {name = "jellyseerr";}}/cert.pem ${certlocname {name = "jellyseerr";}}/key.pem {
          protocols tls1.3
        }
      '';
      "test.nemambyt.com".extraConfig = ''
        encode gzip
        reverse_proxy 100.69.0.100:4242
      '';
      "files.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.60
        redir /.well-known/carddav /remote.php/dav/ 301
        redir /.well-known/caldav /remote.php/dav/ 301
        tls ${certlocname {name = "files";}}/cert.pem ${certlocname {name = "files";}}/key.pem {
          protocols tls1.3
        }
      '';
      "health.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.10.10.90:3110
        tls ${certlocname {name = "health";}}/cert.pem ${certlocname {name = "health";}}/key.pem {
          protocols tls1.3
        }
      '';
    };
  };
}
