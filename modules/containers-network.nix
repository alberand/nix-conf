{
  pkgs,
  config,
  ...
}: {
  systemd.network.enable = true;
  systemd.network.wait-online.enable = false;
  # Need to be removed if NetworkManager is not used anymore
  networking.useNetworkd = true;

  systemd.network = {
    netdevs."cbr" = {
      netdevConfig = {
        Name = "cbr";
        Kind = "bridge";
      };
    };

    networks = {
      "20-br0-uplink" = {
        matchConfig.Name = "cbr";
        networkConfig = {
          Address = "10.10.10.100/24";
        };
      };

      "30-jellyfin-config" = {
        matchConfig.Name = "vb-jellyfin";
        networkConfig = {
          Bridge = "cbr";
          Gateway = "10.10.10.100";
        };
      };

      "40-forgejo-config" = {
        matchConfig.Name = "vb-forgejo";
        networkConfig = {
          Bridge = "cbr";
          Gateway = "10.10.10.100";
        };
      };

      "50-deluge-config" = {
        matchConfig.Name = "veth0";
        networkConfig = {
          Bridge = "cbr";
          #Address = "10.10.10.50/24";
          Gateway = "10.10.10.100";
        };
      };
    };
  };

  environment.etc."containers/networks/cnet.json" = let
    json = pkgs.formats.json {};
  in {
    source = json.generate "cnet.json" {
      name = "cnet";
      driver = "bridge";
      network_interface = "cbr";
      id = "0000000000000000000000000000000000000000000000000000000000000000";
      dns_enabled = false;
      internal = false;
      ipv6_enabled = false;
      ipam_options = {
        driver = "host-local";
      };
      subnets = [
        {
          gateway = "10.10.10.100";
          subnet = "10.10.10.50/24";
        }
      ];
    };
  };
}
