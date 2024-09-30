{ pkgs, lib, ... }: {
  # Disable wait-online as it doesn't seem to work with iptables rules when
  # system is already running. The systemd just can not reach network
  # TODO read this https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  # Enable WireGuard
  networking.wg-quick.interfaces = let
    server_ip = "185.195.233.66";
  in {
    wg0 = {
      address = [
        "10.64.156.60/32"
        "fc00:bbbb:bbbb:bb01::1:9c3b/128"
      ];

      dns = [ "100.64.0.23" ];

      # to match firewall allowedUDPPorts (without this wg
      # uses random port numbers)
      listenPort = 51820;

      # Configure killswitch
      postUp = ''
# Mark packets on the wg0 interface
wg set wg0 fwmark 51820

# Accept kdeconnect connections
${pkgs.iptables}/bin/iptables -A INPUT -i wg0 -p udp \
  --dport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
${pkgs.iptables}/bin/iptables -A INPUT -i wg0 -p tcp \
  --dport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
${pkgs.iptables}/bin/iptables -A OUTPUT -o wg0 -p udp \
  --sport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
${pkgs.iptables}/bin/iptables -A OUTPUT -o wg0 -p tcp \
  --sport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT

# Jellyfin port forwarding for Mullvad VPN
${pkgs.iptables}/bin/iptables \
        -I INPUT \
        -p tcp \
        --dport 55686 \
        -j ACCEPT

# lan
${pkgs.iptables}/bin/iptables \
        -A INPUT \
        -s 192.168.0.0/24 \
        -d 192.168.0.0/24 \
        -m state --state NEW,ESTABLISHED \
        -j ACCEPT
${pkgs.iptables}/bin/iptables \
        -I OUTPUT \
        -s 192.168.0.0/24 \
        -d 192.168.0.0/24 \
        -m state --state NEW,ESTABLISHED \
        -j ACCEPT

# kvart nix container
${pkgs.iptables}/bin/iptables -I OUTPUT -s 10.233.1.0/24 -d 10.233.1.0/24 \
  -j ACCEPT

${pkgs.iptables}/bin/iptables -A INPUT -s 10.88.0.1/16 -d 10.88.0.1/16 \
  -m state --state NEW,ESTABLISHED -j ACCEPT
${pkgs.iptables}/bin/iptables -I OUTPUT -s 10.88.0.1/16 -d 10.88.0.1/16 \
  -m state --state NEW,ESTABLISHED -j ACCEPT

# Exclude OpenVPN tunnel to wedos
${pkgs.iptables}/bin/iptables -A INPUT -s 10.8.0.1/24 -d 10.8.0.14/24 \
  -m state --state NEW,ESTABLISHED -j ACCEPT
${pkgs.iptables}/bin/iptables -I OUTPUT -s 10.8.0.14/24 -d 10.8.0.1/24 \
  -m state --state NEW,ESTABLISHED -j ACCEPT

${pkgs.iptables}/bin/iptables -A INPUT -s 89.221.217.209 -d 192.168.0.100 \
  -m state --state NEW,ESTABLISHED -j ACCEPT
${pkgs.iptables}/bin/iptables -I OUTPUT -s 192.168.0.100 -d 89.221.217.209 \
  -m state --state NEW,ESTABLISHED -j ACCEPT

# Allow deluge web gui
${pkgs.iptables}/bin/iptables -I OUTPUT \
  -p tcp \
  -s localhost \
  --dport 8112 \
  -m state --state NEW,ESTABLISHED \
  -j ACCEPT

# Forbid anything else which doesn't go through wireguard VPN on
# ipV4 and ipV6
${pkgs.iptables}/bin/iptables -A OUTPUT \
  ! -d 192.168.0.0/16 \
  ! -o wg0 \
  -m mark ! --mark $(wg show wg0 fwmark) \
  -m addrtype ! --dst-type LOCAL \
  -j REJECT
${pkgs.iptables}/bin/ip6tables -A OUTPUT \
  ! -o wg0 \
  -m mark ! --mark $(wg show wg0 fwmark) \
  -m addrtype ! --dst-type LOCAL \
  -j REJECT
'';

      postDown = ''
        ${pkgs.iptables}/bin/iptables -F INPUT
        ${pkgs.iptables}/bin/ip6tables -F INPUT
        ${pkgs.iptables}/bin/iptables -F OUTPUT
        ${pkgs.iptables}/bin/ip6tables -F OUTPUT
      '';

      # Path to the private key file.
      privateKeyFile = "/etc/mullvad-vpn.key";

      peers = [{
        publicKey = "1493vtFUbIfSpQKRBki/1d0YgWIQwMV4AQAvGxjCNVM=";
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "${server_ip}:51820";
        persistentKeepalive = 25;
      }];
    };
  };
}
