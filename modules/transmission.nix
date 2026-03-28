{config, ...}: {
  systemd.tmpfiles.rules = [
    "d /bigdata/download                 2755 media media -"
    "d /bigdata/download/download        2755 media media -"
    "d /bigdata/download/incomplete      2755 media media -"
    "d /bigdata/download/watch           2755 media media -"
  ];

  services.transmission = {
    user = "media";
    group = "media";
    enable = true;
    openFirewall = true;
    openRPCPort = true;
    downloadDirPermissions = "750";

    settings = {
      watch-dir-enabled = true;
      watch-dir = "/bigdata/download/watch";
      incomplete-dir-enabled = true;
      incomplete-dir = "/bigdata/download/incomplete";
      download-dir = "/bigdata/download/download";
      umask = "022";
      message-level = 5;
      rpc-port = 9091;
      rpc-host-whitelist = "transmission.alberand.com";
      rpc-host-whitelist-enabled = true;
    };
  };
}
