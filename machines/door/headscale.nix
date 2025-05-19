{config, ...}: {
  containers.headscale = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.10.10.10";
    localAddress = "10.10.10.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";
    config = {
      config,
      lib,
      ...
    }: let
      domain = "door.alberand.com";
    in {
      age.secrets.acme-env.file = ../secrets/acme-env.age;

      services = {
        headscale = {
          enable = true;
          address = "0.0.0.0";
          port = 8080;
          server_url = "https://${domain}";
          dns.nameservers.global = [
            "https://${domain}"
          ];
          settings = {
            logtail.enabled = false;
          };
        };

        acme = {
          acceptTerms = true;
          defaults.email = "andrey.albershteyn@gmail.com";
          defaults.enableDebugLogs = true;
          #defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

          certs."${domain}" = {
            group = config.services.caddy.group;

            domain = "${domain}";
            dnsProvider = "wedos";
            dnsResolver = "ns.wedos.net:53";
            dnsPropagationCheck = true;
            enableDebugLogs = true;
            environmentFile = config.age.secrets.acme-env.path;
          };
        };

        caddy = {
          enable = true;

          virtualHosts = {
            "door.alberand.com".extraConfig = ''
              encode gzip
              reverse_proxy 127.0.0.1:${toString config.services.headscale.port}
              tls /var/lib/acme/${domain}/cert.pem /var/lib/acme/${domain}/key.pem {
                protocols tls1.3
              }
            '';
          };
        };
      };

      environment.systemPackages = [config.services.headscale.package];

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [443];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

      system.stateVersion = "24.11";
    };
  };
}
