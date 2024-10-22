{pkgs, ...}: {
  services.bind = {
    enable = true;
    extraOptions = ''
      dnssec-validation auto;
      allow-query-cache { any; };
    '';
    zones = {
      "lan" = {
        master = true;
        file = let
          #mainserver = "192.168.0.100";
          mainserver = "100.69.0.100";
        in
          pkgs.writeText "lan" ''
            $ORIGIN lan.
            $TTL    604800
            lan.          IN      SOA     home.lan. root.home.lan. (
                                         69         ; Serial
                                         4h         ; refresh
                                        15m         ; retry
                                         8h         ; expire
                                     604800 )       ; Negative Cache TTL
                       IN      NS      home
                       IN      A       ${mainserver}
            ns.home    IN      A       ${mainserver}
            home       IN      A       ${mainserver}
            photos     IN      A       ${mainserver}
            movies     IN      A       ${mainserver}
            food       IN      A       ${mainserver}
            git        IN      A       ${mainserver}
          '';
      };
    };
  };
}
