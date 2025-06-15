{
  config,
  pkgs,
  ...
}: {
  services.tailscale = {
    enable = true;
    port = 41641;
    openFirewall = true;
  };

  # A bit of hack here. The tailscale obtains ip with a bit of a delay, even
  # though tailscaled.service already running. The bind9 ignores tailnet ip and
  # just doesn't listen on it. This is easily fixable by reloading bind service.
  #
  # Here we will actually wait for an IP
  systemd.services.bind-reload-ts = let
    tailscaleInterface = config.services.tailscale.interfaceName;
  in {
    enable = true;
    description = "Reload BIND9 DNS server on assignment of IPv4 with tailscale";
    after = ["tailscaled.service"];
    requires = ["tailscaled.service"];
    bindsTo = ["tailscaled.service"];
    path = with pkgs; [iproute2 systemd];
    # Wait for 50 seconds for IPv4 on ${tailscaleInterface}
    script = ''
      for i in {1..50}; do
        ${pkgs.iproute2}/bin/ip addr show ${tailscaleInterface} | \
          grep inet | \
          grep -v inet6 -q && \
          break;
        sleep 1;
      done

      ${pkgs.systemd}/bin/systemctl reload bind
    '';
  };

  networking = {
    nameservers = ["100.100.100.100"];
    firewall = {
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
    };
  };
}
