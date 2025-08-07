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
        nixxy = "100.69.0.1";
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
          reverse_proxy 10.20.10.2:55686
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

  age.secrets.wg-private-file = {
    file = ../../secrets/jellyfin-wg-server.age;
    mode = "400";
    owner = "root";
    group = "root";
  };

  networking = {
    firewall = {
      allowedUDPPorts = [
        config.networking.wg-quick.interfaces.jellyfin-wg.listenPort
      ];
    };
    wg-quick.interfaces = {
      jellyfin-wg = {
        address = ["10.20.10.1/24"];
        listenPort = 51820;
        privateKeyFile = config.age.secrets.wg-private-file.path;
        peers = [
          {
            publicKey = "Zv787q2jg/1tLLUms3ni0rCag5UuiE2wZEh7ualinAI=";
            allowedIPs = ["10.20.10.2/32"];
          }
        ];
      };
    };
  };
}
