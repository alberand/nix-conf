{
  domain,
  public_ip,
}: {
  config,
  pkgs,
  ...
}: {
  networking.firewall = {
    allowedUDPPorts = [
      53
    ];
    allowedTCPPorts = [
      53
    ];
  };

  services.bind = {
    enable = true;
    listenOn = [
      "127.0.0.1"
      "100.69.0.4"
    ];
    cacheNetworks = [
      "127.0.0.0/24"
      "::1/128"
      "100.69.0.0/24"
    ];
    forwarders = [
      "100.64.0.55"
      "194.242.2.4"
    ];
    extraOptions = ''
      dnssec-validation auto;
    '';
    zones = let
      fqdn = "alberand.com";
      mainserver = "${public_ip}";
    in {
      "${fqdn}" = {
        master = true;
        allowQuery = [
          "any"
        ];
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

          alberand.com. IN      A       ${mainserver}
          *             IN      A       ${mainserver}
        '';
      };
    };
  };

  systemd.services.bind.requires = ["wg-quick-vpn.service"];
}
