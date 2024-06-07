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
