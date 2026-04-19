{pkgs, ...}: {
  systemd.network.enable = true;
  systemd.network.wait-online.enable = false;
  # Need to be removed if NetworkManager is not used anymore
  networking.useNetworkd = true;

  systemd.network = {
    netdevs = {
      "cbr" = {
        netdevConfig = {
          Name = "cbr";
          Kind = "bridge";
        };
      };
      "transmission" = {
        netdevConfig = {
          Name = "transmission";
          Kind = "veth";
        };
        peerConfig = {
          Name = "tc";
        };
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
      "30-transmission" = {
        matchConfig.Name = "tc";
        networkConfig = {
          Address = "10.30.10.100/24";
        };
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

  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [
          "cbr"
        ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      # leases will be valid for 5s
      valid-lifetime = 10800;
      # clients should renew every 6h
      # renew-timer = 21600;
      # clients should start looking for other servers after 9h
      # rebind-timer = 32400;
      subnet4 = [
        {
          id = 1;
          subnet = "10.10.10.0/24";
          interface = "cbr";
          pools = [
            {
              pool = "10.10.10.150 - 10.10.10.200";
            }
          ];
          option-data = [
            {
              name = "routers";
              data = "10.10.10.100";
            }
            {
              name = "domain-name-servers";
              data = "194.242.2.4";
            }
          ];
        }
      ];
    };
  };
}
