{ config, pkgs, ... }:
{
  services.photoprism = {
    enable = true;
    address = "localhost";
    port = 8113;
    originalsPath = "/media/photos";
    settings = {
      PHOTOPRISM_ADMIN_USER = "alberand";
      PHOTOPRISM_ADMIN_PASSWORD = "123456";
    };
  };

  # Unfortunately, symlinks doesn't work somehow, even though Photoprism docs
  # says they should
  fileSystems."/media/photos/phone" = {
    device = config.services.syncthing.dataDir + "/Photos";
    options = [ "bind" ];
  };

  # TODO copy & remove
  fileSystems."/media/photos/julia" = {
    device = "/media/stuff/BUP/Pictures/jpg";
    options = [ "bind" ];
  };
}
