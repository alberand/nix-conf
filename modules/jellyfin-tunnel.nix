# MANUAL ACTION IS REQUIRED!
# Copy your VPN configuration to /etc/openvpn/jellyfin-tunnel.ovpn
# It also needs:
# pull-filter ignore redirect-gateway
{ config, pkgs, lib, ...}: {
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

  # Configure our OpenVPN client
  services.openvpn.servers = {
    jellyfin = {
      config = ''config /etc/openvpn/jellyfin-tunnel.ovpn'';
      autoStart = true;
    };
  };
}
