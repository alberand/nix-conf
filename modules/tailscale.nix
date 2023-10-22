{ pkgs, ... }: {
  services.tailscale = {
    enable = true;
    port = 41641;
  };
  #networking.interfaces.enp34s0.ipv4.routes = [{
    #address = "185.195.233.66";
    #prefixLength = 32;
    #via = "192.168.0.1";
  #}];
}
