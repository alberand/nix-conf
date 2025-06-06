{config, ...}: {
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
}
