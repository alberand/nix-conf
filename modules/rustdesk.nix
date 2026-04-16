{
  config,
  pkgs,
  ...
}: {
  networking.firewall = {
    interfaces.headscale.allowedTCPPorts = [
      21115
      21116
      21118
      # relay
      21117
      21119
    ];
    interfaces.headscale.allowedUDPPorts = [
      21116
    ];
    interfaces.wlo1.allowedTCPPorts = [
      21115
      21116
      21118
      # relay
      21117
      21119
    ];
    interfaces.wlo1.allowedUDPPorts = [
      21116
    ];
  };

  environment.systemPackages = with pkgs; [
    rustdesk-flutter
  ];

  services.rustdesk-server = {
    enable = true;
    openFirewall = true;
    signal.enable = true;
    relay.enable = true;
    signal.relayHosts = [
      "100.69.0.2"
      "192.168.0.100"
    ];
  };
}
