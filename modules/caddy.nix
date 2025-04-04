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
      "movies.alberand.com" = certfor { name = "movies"; };
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

    certs."test.nemambyt.com" = {
      group = config.services.caddy.group;

      domain = "test.nemambyt.com";
      dnsProvider = "cloudflare";
      dnsResolver = "aron.ns.cloudflare.com";
      dnsPropagationCheck = true;
      enableDebugLogs = true;
      environmentFile = config.age.secrets.acme-env.path;
    };
  };

  services.caddy = {
    enable = true;

    virtualHosts = let
      dashboard = pkgs.stdenv.mkDerivation {
        name = "dashboard";

        src = ../configs/dashboard.html;

        phases = ["installPhase"];

        installPhase = ''
          mkdir $out
          cp $src $out/index.html
        '';
      };
      certloc = "/var/lib/acme/whereisiss.com";
      certlocname = {name}: "/var/lib/acme/${name}.alberand.com";
      nbcertloc = "/var/lib/acme/test.nemambyt.com";
    in {
      "home.alberand.com".extraConfig = ''
        encode gzip
        root * ${dashboard}/
        file_server
        tls ${certlocname {name = "home";}}/cert.pem ${certlocname {name = "home";}}/key.pem {
          protocols tls1.3
        }
      '';
      "movies.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:55686
        tls ${certlocname {name = "movies";}}/cert.pem ${certlocname {name = "movies";}}/key.pem {
          protocols tls1.3
        }
      '';
      "jellyfin.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:55686
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
      "photos.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:8113
        tls ${certlocname {name = "photos";}}/cert.pem ${certlocname {name = "photos";}}/key.pem {
          protocols tls1.3
        }
      '';
      "food.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:8114
        tls ${certlocname {name = "food";}}/cert.pem ${certlocname {name = "food";}}/key.pem {
          protocols tls1.3
        }
      '';
      "git.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:3000
        tls ${certlocname {name = "git";}}/cert.pem ${certlocname {name = "git";}}/key.pem {
          protocols tls1.3
        }
      '';
      "test.nemambyt.com".extraConfig = ''
        encode gzip
        reverse_proxy 10.233.1.2:4242
        tls ${nbcertloc}/cert.pem ${nbcertloc}/key.pem {
          protocols tls1.3
        }
      '';
    };
  };
}
