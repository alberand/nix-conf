{pkgs, ...}: {
  services.tailscale = {
    enable = true;
    port = 41641;
    openFirewall = true;
  };
  networking = {
    nameservers = ["100.100.100.100"];
    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
    };
  };
}
