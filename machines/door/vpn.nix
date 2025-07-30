{
  public_ip,
  domain,
}: {
  config,
  pkgs,
  ...
}: {
  age.secrets.mullvad-key = {
    file = ../../secrets/door-mullvad-key.age;
    mode = "444";
    owner = "root";
    group = "root";
  };

  networking = {
    nftables = {
      enable = true;
      tables.headscale-wg = {
        enable = true;
        family = "ip";

        # Mark all packets NOT sent to headscale nodes, on headscale interface
        # This mark used used by wg-quick to route these packets to wireguard
        # tunnel
        content = ''
          chain preraw {
            type filter hook prerouting priority raw; policy accept;
            iifname "headscale" ip daddr != 100.69.0.0/16 mark set 51820;
          }
        '';
      };
    };
    firewall = {
      allowedUDPPorts = [
        53
        config.networking.wg-quick.interfaces.vpn.listenPort
      ];
      allowedTCPPorts = [
        53
      ];
    };
  };

  # Enable WireGuard
  networking.wg-quick.interfaces = let
    server_ip = "185.65.135.72";
    dns = "100.69.0.4";
  in {
    vpn = {
      autostart = true;
      address = ["10.68.180.218/32" "fc00:bbbb:bbbb:bb01::5:b4d9/128"];
      dns = [dns];

      # to match firewall allowedUDPPorts (without this wg
      # uses random port numbers)
      listenPort = 51820;

      # Path to the private key file.
      privateKeyFile = config.age.secrets.mullvad-key.path;

      # This allows the wireguard server to route your traffic to the internet
      # and hence be like a VPN
      postUp = ''
        ${pkgs.wireguard-tools}/bin/wg set vpn fwmark off

        # table inet tailscale-wg { for ipv4 + ipv6
        ${pkgs.iproute2}/bin/ip -4 rule del not fwmark 51820 table 51820
        ${pkgs.iproute2}/bin/ip -6 rule del not fwmark 51820 table 51820

        ${pkgs.iproute2}/bin/ip -4 rule add fwmark 51820 table 51820
        ${pkgs.iproute2}/bin/ip -6 rule add fwmark 51820 table 51820
      '';

      peers = [
        {
          publicKey = "5rVa0M13oMNobMY7ToAMU1L/Mox7AYACvV+nfsE7zF0=";
          allowedIPs = ["0.0.0.0/0" "${dns}/32"];
          endpoint = "${server_ip}:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
