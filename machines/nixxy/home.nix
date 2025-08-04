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
      config = {
        default_apps = {
          calendar_client = "thunderbird";
          terminal = "kitty";
          browser = "${pkgs.firefox}/bin/firefox %u";
        };
        units = {
          lengths = "meters";
          weights = "kg";
          volumes = "l";
          temperatures = "C";
          currency = "eur";
        };
        binds = {
          up = "control-k";
          down = "control-j";
          left = "control-ih";
          right = "control-l";
          context = "control-i";
          modifier = "control";
          exec_inplace = "control-return";
        };
      };
      aliases = {
        workfox = {
          name = "workfox";
          icon = "firefox";
          keywords = "firefox";
          exec = "${pkgs.firefox}/bin/firefox -P RedHat";
        };
      };
      launchers = [
        {
          name = "App Launcher";
          type = "app_launcher";
          args = {};
          priority = 1;
          home = true;
        }
        {
          name = "Clipboard";
          type = "clipboard-execution";
          args.capabilities = [
            "url"
            "colors.hex"
            "colors.rgb"
            "colors.hsl"
            "calc.math"
            "calc.lengths"
            "calc.weights"
            "calc.temperatures"
          ];
          priority = 2;
          home = true;
        }
        {
          name = "Emoji Picker";
          type = "emoji_picker";
          alias = "em";
          args = {
            default_skin_tone = "Simpsons";
          };
          priority = 3;
          home = "Search";
        }
        {
          name = "Web Search";
          display_name = "Duckduckgo Search";
          tag_start = "{keyword}";
          tag_end = "{keyword}";
          alias = "gg";
          type = "web_launcher";
          exec = "${pkgs.firefox}/bin/firefox %u";
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
