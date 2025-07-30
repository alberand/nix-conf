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

  # Enable WireGuard
  networking.wg-quick.interfaces = let
    server_ip = "193.32.127.68";
  in {
    wg0 = {
      autostart = false;
      address = ["10.70.12.188/32" "fc00:bbbb:bbbb:bb01::7:cbb/128"];

      dns = ["100.64.0.55"];

      # to match firewall allowedUDPPorts (without this wg
      # uses random port numbers)
      listenPort = 51820;

      # Path to the private key file.
      privateKeyFile = "/etc/mullvad-vpn.key";

      peers = [
        {
          publicKey = "5Ms10UxGjCSzwImTrvEjcygsWY8AfMIdYyRvgFuTqH8=";
          allowedIPs = ["0.0.0.0/0" "::/0"];
          endpoint = "${server_ip}:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
