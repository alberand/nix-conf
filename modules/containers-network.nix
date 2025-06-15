{pkgs, ...}: {
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
      # Assign IP to host end of a bridge (although I suppose all ends of the
      # bridge are on the host side of things)
      "20-cbr-uplink" = {
        matchConfig.Name = "cbr";
        networkConfig = {
          Address = "10.10.10.100/24";
        };
        routes = [
          {
            Gateway = "10.10.10.100";
            Source = "10.10.10.0/24";
            Destination = "10.10.10.0/24";
          }
        ];
      };
    };
  };

  # Podman container network attached to nspawn network via 'cbr' bridge
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
      options = {
        mode = "unmanaged";
      };
      subnets = [
        {
          gateway = "10.10.10.100";
          subnet = "10.10.10.0/24";
        }
      ];
    };
  };
}
