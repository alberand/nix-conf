{ config, pkgs, lib, ... }: {
  imports = [
    ../../modules/home-base.nix
  ];

  home.username = "alberand";
  home.homeDirectory = "/home/alberand";

  home.packages = with pkgs; [
    cargo
    (discord.override { nss = pkgs.nss_latest; })
    freecad
    gimp
    inkscape
    jellyfin
    kicad
    minecraft
    prismlauncher # Minecraft launcher
    rust-analyzer
    steam
    tdesktop # telegram
    thunderbird
    wireshark
  ];
}
