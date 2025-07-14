{pkgs, ...}: {
  services.bind = {
    enable = true;
    listenOn = [
      "100.69.0.100"
      "192.168.0.100"
      "10.10.10.100"
    ];
    forwarders = [
      "1.1.1.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    extraOptions = ''
      dnssec-validation auto;
    '';
    cacheNetworks = [
      "127.0.0.0/24"
      "::1/128"
      "100.69.0.0/24"
    ];
    zones = let
      fqdn = "alberand.com";
      mainserver = "100.69.0.100";
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
          home         IN      A       ${mainserver}
          git           IN      A       ${mainserver}
          food          IN      A       ${mainserver}
          photos        IN      A       ${mainserver}
          jellyseerr    IN      A       ${mainserver}
          files         IN      A       ${mainserver}
          health        IN      A       ${mainserver}
          jellyfin      IN      A       89.221.212.102
        '';
      };
    };
  };
}
