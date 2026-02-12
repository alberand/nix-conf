{...}: {
  services.grafana = {
    enable = true;
    settings.server = {
      http_port = 3000;
      http_addr = "127.0.0.1";
    };
    provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        url = "http://127.0.0.1:9090";
        access = "proxy";
      }
    ];
  };

  services.prometheus = {
    enable = true;
    port = 9090;

    exporters.node = {
      enable = true;
      port = 9100;
      # specific collectors to enable systemd monitoring
      enabledCollectors = ["systemd"];
      # Optional: If you want to ignore specific noisy services, you can filter here.
      # extraFlags = [ "--collector.systemd.unit-exclude=(mount|scope|slice)$" ];
    };

    # Configure the scrape job to talk to Node Exporter
    scrapeConfigs = [
      {
        job_name = "nixos-node";
        static_configs = [
          {
            targets = ["127.0.0.1:9100"];
          }
        ];
      }
    ];
  };
}
