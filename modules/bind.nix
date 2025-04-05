{pkgs, ...}: {
  services.bind = {
    enable = true;
    forwarders = [
      "1.1.1.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    extraOptions = ''
      dnssec-validation auto;
      allow-query-cache { any; };
    '';
    zones = let
      fqdn = "alberand.com";
      mainserver = "100.69.0.100";
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

          *             IN      A       ${mainserver}
          jellyfin      IN      A       89.221.212.102
        '';
      };
    };
  };
}
