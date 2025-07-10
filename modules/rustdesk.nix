{config, pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    rustdesk-flutter
  ];

  services.rustdesk-server = {
    enable = true;
    openFirewall = true;
    signal.enable = true;
    relay.enable = true;
    signal.relayHosts = ["100.69.0.100"];
  };
}
