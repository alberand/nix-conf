{
  config,
  pkgs,
  lib,
  ...
}: {
  # Disable wait-online as it doesn't seem to work with iptables rules when
  # system is already running. The systemd just can not reach network
  # TODO read this https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  networking.firewall = {
    allowedUDPPorts = [config.networking.wg-quick.interfaces.wg0.listenPort];
  };

  nixpkgs.overlays = [
    (self: super: {
      wireguard-tools = super.wireguard-tools.overrideAttrs rec {
        version = "1.0.20250521";
        src = pkgs.fetchzip {
          url = "https://git.zx2c4.com/wireguard-tools/snapshot/wireguard-tools-${version}.tar.xz";
          sha256 = "sha256-V9yKf4ZvxpOoVCFkFk18+130YBMhyeMt0641tn0O0e0=";
        };
        patches = [
          ../patches/0001-wg-quick-linux-set-priority-of-the-ip-rule-higher-th.patch
        ];
      };
    })
  ];

  # Enable WireGuard
  networking.wg-quick.interfaces = let
    server_ip = "185.195.233.66";
  in {
    wg0 = {
      address = ["10.64.156.60/32" "fc00:bbbb:bbbb:bb01::1:9c3b/128"];

      dns = ["100.64.0.23"];

      # to match firewall allowedUDPPorts (without this wg
      # uses random port numbers)
      listenPort = 51820;

      # Path to the private key file.
      privateKeyFile = "/etc/mullvad-vpn.key";

      peers = [
        {
          publicKey = "1493vtFUbIfSpQKRBki/1d0YgWIQwMV4AQAvGxjCNVM=";
          allowedIPs = ["0.0.0.0/0" "::/0"];
          endpoint = "${server_ip}:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
