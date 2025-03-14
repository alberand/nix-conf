{pkgs, ...}: {
  home.packages = with pkgs; [beaker-client];

  home.file = {
    ".beaker_client/config" = {source = ../configs/beaker-config;};
  };

  # Already done in work-vpn
  #security.pki.certificates = let
  #  certfile = builtins.readFile ../openvpn/RedHatInternalCA.pem;
  #in [
  #  certfile
  #];
}
