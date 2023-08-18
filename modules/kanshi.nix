{config, pkgs, ...}:
{
  services.kanshi = {
    enable = true;

    profiles = {
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            scale = 1.0;
            status = "enable";
          }
        ];
      };

      home = {
        outputs = [
          {
            criteria = "Dell Inc. DELL P2414H KKMMW6451WCS";
            mode = "1920x1080@60Hz";
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
      };
    };
  };
}
