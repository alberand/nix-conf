{
  domain,
  public_ip,
}: {
  config,
  pkgs,
  ...
}: {
  networking.firewall = {
    enable = true;
    interfaces.headscale = {
      allowedTCPPorts = [
        53
      ];
      allowedUDPPorts = [
        53
      ];
    };
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
      vps_ip = "${public_ip}";
      nixxy = "100.69.0.2";
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
          ns            IN      A       ${vps_ip}

          alberand.com. IN      A       ${vps_ip}
          door          IN      A       ${vps_ip}
          id            IN      A       ${vps_ip}
          jellyfin      IN      A       ${vps_ip}
          *             IN      A       ${nixxy}
        '';
      };
    };
  };

  systemd.services.bind.requires = ["wg-quick-vpn.service"];
}
