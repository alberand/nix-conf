{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/home-base.nix
  ];

  home.username = "alberand";
  home.homeDirectory = "/home/alberand";

  xdg.desktopEntries = {
    workfox = {
      name = "workfox";
      exec = "workfox";
      genericName = "Work Web Browser";
      icon = "firefox";
      categories = ["Network" "WebBrowser"];
      terminal = false;
      startupNotify = true;
    };
  };

  home.packages = with pkgs; let
    workfox =
      writeShellScriptBin "workfox"
      "exec -a $0 ${firefox}/bin/firefox -P RedHat $@";
  in [
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
    workfox
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
}
