{config, pkgs, ...}:
{

  programs.eww = {
    enable = true;
    configDir = ../configs/eww/dashboard;
  };
}
