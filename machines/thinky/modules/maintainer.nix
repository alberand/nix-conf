{pkgs, ...}: {
  home.packages = with pkgs; [kup xfsprogs-release];

  home.file = {".kuprc" = {source = ../configs/kuprc;};};
}
