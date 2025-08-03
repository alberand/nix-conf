{sherlock}: {
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/home-base.nix
    sherlock.homeModules.default
  ];

  home.username = "alberand";
  home.homeDirectory = "/home/alberand";

  home.packages = with pkgs; [
    cargo
    (discord.override {nss = pkgs.nss_latest;})
    freecad
    gimp
    inkscape
    kicad
    prismlauncher # Minecraft launcher
    rust-analyzer
    steam
    tdesktop # telegram
    thunderbird
    libreoffice
    rustfmt
    openrgb
    tdesktop
    vlc
  ];

  home.file = {
    ".shrc.local" = {source = ./configs/shrc.local;};
    ".config/jj/config.toml" = {source = ../../configs/jj.toml;};
  };

  # Script to check work VPN connectivity
  programs.waybar.settings.mainBar."custom/vpn".exec =
    builtins.readFile ./configs/vpn-check.sh;

  wayland.windowManager.sway.config = {
    startup = [
      {command = "swaymsg 'workspace 1; exec firefox'";}
      {command = "swaymsg 'workspace 2; exec kitty'";}
      {command = "swaymsg 'workspace 10; exec thunderbird'";}
      {command = "swaymsg 'exec \"sleep 1; flameshot\"'";}
    ];
  };

  programs.sherlock = {
    enable = true;
    settings = {
      launchers = [
        {
          name = "App Launcher";
          type = "app_launcher";
          args = {};
          priority = 1;
          home = true;
        }
        {
          name = "Web Search";
          display_name = "Duckduckgo Search";
          tag_start = "{keyword}";
          tag_end = "{keyword}";
          alias = "s";
          type = "web_launcher";
          args = {
            search_engine = "duckduckgo";
            icon = "duckduckgo";
          };
          priority = 100;
        }
      ];
    };
  };
}
