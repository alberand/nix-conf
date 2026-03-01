{config, ...}: {
  age.secrets.pinchflat = {
    file = ../secrets/pinchflat.age;
    mode = "400";
    owner = "pinchflat";
    group = "pinchflat";
  };

  users.users.pinchflat = {
    description = "Pinchflat user - youtube downloader user";
    uid = 8945;
    extraGroups = [
      "media"
      "pinchflat"
    ];
  };
  users.groups.pinchflat.gid = 8945;

  services.pinchflat = {
    enable = true;
    openFirewall = true;
    port = 8945;
    mediaDir = "/media/youtube";
    user = "pinchflat";
    group = "pinchflat";
    secretsFile = config.age.secrets.pinchflat.path;
  };
}
