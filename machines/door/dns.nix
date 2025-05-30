{
  domain,
  public_ip,
}: {config, ...}: {
  containers.headscale = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.10.10.10";
    localAddress = "10.10.10.12";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::3";
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      services.bind = {
        enable = true;
        forwarders = [
          "1.1.1.1"
          "194.242.2.2"
        ];
        extraOptions = ''
          dnssec-validation auto;
          allow-query-cache { any; };
        '';
        zones = let
          fqdn = "alberand.com";
          mainserver = "${public_ip}";
        in {
          "${fqdn}" = {
            allowQuery = [
              "localhost"
              "100.69.0.0/24"
            ];
            master = true;
            file = pkgs.writeText "${fqdn}" ''
              $ORIGIN ${fqdn}.
              $TTL    604800
              @              IN      SOA     ns admin (
                                           69         ; Serial
                                           4h         ; refresh
                                          15m         ; retry
                                           8h         ; expire
                                       604800         ; Negative Cache TTL
                                       )
              @             IN      NS      ns
              ns            IN      A       ${mainserver}

              alberand.com. IN      A       185.199.108.153
              *             IN      A       ${mainserver}
              jellyfin      IN      A       89.221.212.102
            '';
          };
        };
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [53];
        };
        # Use systemd-resolved inside the container
        # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;

      system.stateVersion = "25.05";
    };
  };
}
