# REQUIRED MANUAL ACTION:
#
# You need to create "./openvpn" directory and put there:
# - client.up - shell script called by OpenVPN while establishing connection
# - client.down - shell script called by OpenVPN while closing connection
# - ovpn-ams2-tcp.conf - OpenVPN configuration files. Need modifications!!!
#
# All those files are private! You can obtain them from help portal.
#
# Modification to OpenVPN configuration file:
# 1. Replace
#     "ca /etc/pki/tls/certs/2015-RH-IT-Root-CA.pem"
#    with
#     "ca /etc/pki/tls/certs/redhat-root-ca.crt"
# 2. Replace:
#     plugin /usr/lib64/openvpn/plugins/openvpn-plugin-down-root.so /etc/openvpn/client.down
#    with:
#     plugin openvpn-plugin-down-root.so /etc/openvpn/client.down
# This can be any close to you server. I'm here using Amsterdam. If you use
# different .conf file change it below in client configuration
# services.openvpn.servers.vpn.config.
#
# See logs:
#   journalctl -u openvpn-vpn.service | tail -n20
# Start (ask for user and password):
#   systemctl start openvpn-vpn.service
# Check that everything works:
#   curl <beaker url>
{pkgs, ...}: {
  networking.firewall = {
    allowedTCPPorts = [
      1194 # openvpn
    ];
    allowedUDPPorts = [
      1194 # openvpn
    ];
  };
  users.users = {
    openvpn = {
      name = "openvpn";
      group = "openvpn";
      isNormalUser = true;
      uid = 1100;
    };
  };

  users.groups.openvpn = {
    name = "openvpn";
    members = ["openvpn"];
    gid = 1100;
  };

  security.pki = {
    certificateFiles = [
      "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ../secrets/redhat.crt
    ];
  };

  systemd.services.nix-daemon.serviceConfig.Environment = [
    # NOTE: this must be `ca-certificates.crt`, not `ca-bundle.crt` or any other value
    "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
  ];

  # Configure our OpenVPN client
  services.openvpn.servers = {
    vpn = {
      config = "config /etc/openvpn/ovpn-1-rhvpn-tcp.conf";
      # Don't autostart as VPN needs credentials
      autoStart = false;
      up = builtins.readFile ../configs/client.up;
      down = builtins.readFile ../configs/client.down;
    };
    vpn-udp = {
      config = "config /etc/openvpn/ovpn-1-rhvpn-udp.conf";
      # Don't autostart as VPN needs credentials
      autoStart = false;
      up = builtins.readFile ../configs/client.up;
      down = builtins.readFile ../configs/client.down;
    };
    ams = {
      config = "config /etc/openvpn/ovpn-ams2-tcp.conf";
      # Don't autostart as VPN needs credentials
      autoStart = false;
      up = builtins.readFile ../configs/client.up;
      down = builtins.readFile ../configs/client.down;
    };
    ams-udp = {
      config = "config /etc/openvpn/ovpn-ams2-udp.conf";
      # Don't autostart as VPN needs credentials
      autoStart = false;
      up = builtins.readFile ../configs/client.up;
      down = builtins.readFile ../configs/client.down;
    };
    brq2 = {
      config = "config /etc/openvpn/ovpn-brq2-tcp.conf";
      # Don't autostart as VPN needs credentials
      autoStart = false;
      up = builtins.readFile ../configs/client.up;
      down = builtins.readFile ../configs/client.down;
    };
    brq2-proxy = {
      config = "config /etc/openvpn/ovpn-brq2-tcp-proxy.conf";
      # Don't autostart as VPN needs credentials
      autoStart = false;
      up = builtins.readFile ../configs/client.up;
      down = builtins.readFile ../configs/client.down;
    };
    brq2-udp = {
      config = "config /etc/openvpn/ovpn-brq2-udp.conf";
      # Don't autostart as VPN needs credentials
      autoStart = false;
      up = builtins.readFile ../configs/client.up;
      down = builtins.readFile ../configs/client.down;
    };
  };
}
