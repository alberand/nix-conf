{pkgs, ...}: {
  services.tailscale = {
    enable = true;
    port = 41641;
    openFirewall = true;
  };
  networking = {
    nameservers = ["8.8.8.8" "1.1.1.1"];
    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
    };
  };
}
