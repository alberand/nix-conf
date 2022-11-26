{ pkgs, ... }:

{
    # Route for wireguard VPN. Not sure why it's needed but without the route
    # the system can not reach VPN server. TODO investigate it
    networking.interfaces.enp34s0.ipv4.routes = [{
      address = "185.195.233.66";
      prefixLength = 32;
      via = "192.168.0.1";
    }];
    # Restart network interface upon suspend (don't know how to make services
    # restart by itself). We need to restart network-addresses-enp34s0 as it
    # creates route specified above. After suspend dhcpcd flushes all routes. We
    # need to add the route and restart our VPN tunnel (don't know why also).
    systemd.services.suspend-restart = {
      wantedBy = [ "suspend.target" ];
      after = [ "suspend.target" ];
      description = "Restart network interface to initialize routes";
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.systemd}/bin/systemctl --no-block restart \
            network-addresses-enp34s0.service
        '';         
      };
    };
    # Temporary fix for https://github.com/NixOS/nixpkgs/issues/162260
    systemd.services.network-addresses-enp34s0 = {
      after = [ "dhcpcd.service" ];
      preStart = "sleep 10\n";
    };
    systemd.services.wireguard-wg0 = {
      after = [ "network-addresses-enp34s0.service" ];
      requires = [ "network-addresses-enp34s0.service" ];
    };

	# Enable WireGuard
	networking.wireguard.interfaces = let
		server_ip = "185.195.233.66";
	in {
		wg0 = {
			# Determines the IP address and subnet of the client's
			# end of the tunnel interface.
			ips = [ "10.64.156.60/32" ];
			# to match firewall allowedUDPPorts (without this wg
			# uses random port numbers)
			listenPort = 51820;

            # Configure killswitch
            postSetup = ''
              # Mark packets on the wg0 interface
              wg set wg0 fwmark 51820

              ${pkgs.iptables}/bin/iptables -I OUTPUT ! -d 192.168.0.0/16 ! -o wg0 -m mark ! \
                --mark $(wg show wg0 fwmark) -m addrtype ! \
                --dst-type LOCAL -j REJECT
              ${pkgs.iptables}/bin/iptables -I OUTPUT ! -d 100.75.148.70/24 ! -o wg0 -m mark ! \
                --mark $(wg show wg0 fwmark) -m addrtype ! \
                --dst-type LOCAL -j REJECT
              ${pkgs.iptables}/bin/ip6tables -I OUTPUT ! -o wg0 -m mark ! \
                --mark $(wg show wg0 fwmark) -m addrtype ! \
                --dst-type LOCAL -j REJECT

              # Exclude deluge web gui from firewall rules
              ${pkgs.iptables}/bin/iptables -I OUTPUT -p tcp --dport 8112 \
                -j ACCEPT

              # Exclude KDE-connect ports
              ${pkgs.iptables}/bin/iptables -I INPUT -i wg0 -p udp \
                --dport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
              ${pkgs.iptables}/bin/iptables -I INPUT -i wg0 -p tcp \
                --dport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
              ${pkgs.iptables}/bin/iptables -A OUTPUT -o wg0 -p udp \
                --sport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
              ${pkgs.iptables}/bin/iptables -A OUTPUT -o wg0 -p tcp \
                --sport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT

              ${pkgs.iptables}/bin/iptables -I INPUT -i tailscale0 -p udp \
                -j ACCEPT
              ${pkgs.iptables}/bin/iptables -I INPUT -i tailscale0 -p tcp \
                -j ACCEPT
              ${pkgs.iptables}/bin/iptables -A OUTPUT -o tailscale0 -p udp \
                -j ACCEPT
              ${pkgs.iptables}/bin/iptables -A OUTPUT -o tailscale0 -p tcp \
                -j ACCEPT
            '';

            postShutdown = ''
              ${pkgs.iptables}/bin/iptables -D OUTPUT ! -d 192.168.0.0/16 ! -o wg0 -m mark ! \
                --mark $(wg show wg0 fwmark) -m addrtype ! \
                --dst-type LOCAL -j REJECT
              ${pkgs.iptables}/bin/ip6tables -D OUTPUT ! -o wg0 -m mark ! \
                --mark $(wg show wg0 fwmark) -m addrtype ! \
                --dst-type LOCAL -j REJECT

              ${pkgs.iptables}/bin/iptables -D OUTPUT -p tcp -s --dport 8112 \
                -j ACCEPT

              ${pkgs.iptables}/bin/iptables -D INPUT -i wg0 -p udp \
                --dport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
              ${pkgs.iptables}/bin/iptables -D INPUT -i wg0 -p tcp \
                --dport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
              ${pkgs.iptables}/bin/iptables -D OUTPUT -o wg0 -p udp \
                --sport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
              ${pkgs.iptables}/bin/iptables -D OUTPUT -o wg0 -p tcp \
                --sport 1714:1764 -m state --state NEW,ESTABLISHED -j ACCEPT
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
