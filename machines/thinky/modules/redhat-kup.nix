{config, pkgs}: {
  home.packages = with pkgs; [
    kup
  ];

  home.file = {
    ".kuprc" = {
      source = ../configs/kuprc;
    };
  };
}
