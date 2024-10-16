{pkgs, ...}: {
  services.tailscale = {
    enable = true;
    port = 41641;
    openFirewall = true;
  };
  networking.nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
  networking.search = [ "tail5708e.ts.net" ];

  #networking.interfaces.enp34s0.ipv4.routes = [{
  #address = "185.195.233.66";
  #prefixLength = 32;
  #via = "192.168.0.1";
  #}];
}
