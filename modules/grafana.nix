{ pkgs, ... }: {
  services.grafana = {
    enable = false;
    settings.server = {
      http_port = 3000;
      http_addr = "127.0.0.1";
    };
  };
}
