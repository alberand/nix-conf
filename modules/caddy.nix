{pkgs, config, ...}: {
  security.acme = {
    acceptTerms = true;
    defaults.email = "andrey.albershteyn@gmail.com";
    defaults.enableDebugLogs = true;
    #defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

   age.secrets.acme-env.file = ./secrets/acme-env.age;

    certs."whereisiss.com" = {
      group = config.services.caddy.group;

      domain = "whereisiss.com";
      extraDomainNames = [
        "food.whereisiss.com"
        "movies.whereisiss.com"
        "photos.whereisiss.com"
      ];
      dnsProvider = "wedos";
      dnsResolver = "ns.wedos.net:53";
      dnsPropagationCheck = true;
      enableDebugLogs = true;
      environmentFile = config.age.secrets.acme-env.path;
    };
    certs."git.alberand.com" = {
      group = config.services.caddy.group;

      domain = "git.alberand.com";
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
      dashboard =
        pkgs.stdenv.mkDerivation {
          name = "dashboard";

          src = ../configs/dashboard.html;

          phases = [ "installPhase" ];

          installPhase = ''
            mkdir $out
            cp $src $out/index.html
          '';
        };
        certloc = "/var/lib/acme/whereisiss.com";
        gitcertloc = "/var/lib/acme/git.alberand.com";
    in {
      "home.lan".extraConfig = ''
        tls internal
        encode gzip
        root * ${dashboard}/
        file_server
      '';
      "movies.lan".extraConfig = ''
        tls internal
        encode gzip
        reverse_proxy 127.0.0.1:55686
      '';
      "photos.lan".extraConfig = ''
        tls internal
        encode gzip
        reverse_proxy 127.0.0.1:8113
      '';
      "food.lan".extraConfig = ''
        tls internal
        encode gzip
        reverse_proxy 127.0.0.1:8114
      '';
      "home.whereisiss.com".extraConfig = ''
        encode gzip
        root * ${dashboard}/
        file_server
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
      "movies.whereisiss.com".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:55686
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
      "photos.whereisiss.com".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:8113
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
      "food.whereisiss.com".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:8114
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
      "git.whereisiss.com".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:3000
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
      "git.alberand.com".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:3000
        tls ${gitcertloc}/cert.pem ${gitcertloc}/key.pem {
          protocols tls1.3
        }
      '';
    };
  };
}
