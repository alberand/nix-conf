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

  home.file = {
    ".shrc.local" = { source = ./configs/.shrc.local; };
  };

  # Script to check work VPN connectivity
  programs.waybar.settings.mainBar."custom/vpn".exec =
    (builtins.readFile ./configs/vpn-check.sh);

  wayland.windowManager.sway.config = {
    startup = [
      { command = "swaymsg 'workspace 1; exec firefox'"; }
      { command = "swaymsg 'workspace 2; exec kitty'"; }
      { command = "swaymsg 'workspace 10; exec thunderbird'"; }
      { command = "swaymsg 'exec \"sleep 1; flameshot\"'"; }
      { command = "kdeconnect-indicator"; }
      { command = "swaymsg 'workspace 9; exec \"sleep 1; telegram-desktop\"'"; }
    ];
  };
}
