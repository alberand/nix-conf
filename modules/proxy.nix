{config, ...}: let
  port = 3333;
in {
  networking.firewall.allowedTCPPorts = [
    port
  ];

  services.privoxy = {
    enable = true;
    settings = {
      listen-address = "192.168.0.101:${builtins.toString port}";
      # Deny all connections first (default deny)
      deny-access = "0.0.0.0/0";

      # Allow only specific IP address
      permit-access = "192.168.0.100";
    };
  };
}
