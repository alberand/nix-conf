{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    kanshi
  ];

  services.kanshi = {
    enable = true;

    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            scale = 1.0;
            status = "enable";
          }
        ];
      }

      {
        profile.name = "dual-monitor";
        profile.outputs = [
          {
            criteria = "Dell Inc. DELL P2414H KKMMW6451WCS";
            mode = "1920x1080@60Hz";
            position = "0,0";
          }
          {
            criteria = "Hewlett Packard HP E231 3CQ4231P8R";
            mode = "1920x1080@60Hz";
            transform = "90";
            position = "-1080,-600";
          }
        ];
      }

      {
        profile.name = "home";
        profile.outputs = [
          {
            criteria = "Dell Inc. DELL P2414H KKMMW6451WCS";
            mode = "1920x1080@60Hz";
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
      }
    ];
  };
}
