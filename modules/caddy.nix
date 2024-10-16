{pkgs, ...}: {
  services.caddy = {
    enable = true;

    virtualHosts = {
      "jellyfin.home".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:55686
      '';
      "photos.home".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:8113
      '';
      "food.home".extraConfig = ''
        encode gzip
        reverse_proxy 127.0.0.1:8114
      '';
    };
  };
}
