{pkgs, ...}: {
  home.packages = with pkgs; [kup];

  home.file = {".kuprc" = {source = ../configs/kuprc;};};
  home.file = {".config/jj/config.toml" = {source = ../configs/jj.toml;};};
}
