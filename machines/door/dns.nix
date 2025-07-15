{
  domain,
  public_ip,
}: {config, pkgs, ...}: {
  services.bind = {
    enable = true;
    listenOn = [
      "127.0.0.1"
    ];
    cacheNetworks = [
      "127.0.0.0/24"
      "::1/128"
      "100.69.0.0/24"
    ];
    forwarders = [
      "194.242.2.2"
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

          alberand.com. IN      A       185.199.108.153
          *             IN      A       ${mainserver}
          jellyfin      IN      A       89.221.212.102
        '';
      };
    };
  };
}
