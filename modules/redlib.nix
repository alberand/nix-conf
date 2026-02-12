{config, ...}: {
  services.redlib = {
    openFirewall = true;
    port = 9001;
    enable = true;
    address = "0.0.0.0";
    settings = {
      REDLIB_DEFAULT_SHOW_NSFW = "on";
      REDLIB_DEFAULT_USE_HLS = "on";
      THEME = "dark";
    };
  };
}
