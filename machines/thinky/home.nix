{agenix}: {
  config,
  pkgs,
  lib,
  ...
}: rec {
  imports = [
    agenix.homeManagerModules.default
    ../../modules/home-base.nix
    ../../modules/neomutt.nix
    ../../modules/redhat-beaker.nix
    ./modules/maintainer.nix
  ];

  home.username = "aalbersh";
  home.homeDirectory = "/home/aalbersh";

  home.packages = with pkgs; [
    xfstestsdb
    # Script to open serial console to Beaker machine
    (let
      wrapper =
        writeShellScriptBin "con" (builtins.readFile ./configs/console.sh);
    in
      pkgs.symlinkJoin {
        name = "conserver-bkr";
        paths = [(conserver.override {gssapiSupport = true;}) wrapper];
      })
    # Git script to backport fixes from upstream to downstream
    (writeShellScriptBin "git-bp" (builtins.readFile ./configs/git-bp))
    # Beaker script to reserve machines for testing
    (writeShellScriptBin "machine" (builtins.readFile ./configs/machine))
  ];

  home.file = {
    ".notmuch-config" = {source = ./configs/notmuch-config;};
    ".redhat/notmuch-hook.sh" = {source = ./configs/notmuch-hook.sh;};
    ".redhat/neomutt-jira.sh" = {source = ./configs/neomutt-jira.sh;};
    ".shrc.local" = {source = ./configs/shrc.local;};
    ".consolerc" = {source = ./configs/consolerc;};
    ".config/jj/config.toml" = {source = ../../configs/jj.toml;};
  };

  programs.gpg = {
    enable = true;
    settings = {default-key = "46A7EA18AC33E108";};
  };

  programs.git = {
    extraConfig = {user = {signingkey = "46A7EA18AC33E108";};};
    ignores = [
      ".envrc"
      # patch -p1 
      "*.orig"
      "*.rej"
    ];
  };

  # Auto-run applications
  wayland.windowManager.sway.config = {
    startup = [
      {command = "swaymsg 'workspace 1; exec firefox'";}
      {command = "swaymsg 'workspace 2; exec kitty'";}
      {command = "swaymsg 'exec \"sleep 1; flameshot\"'";}
    ];

    keybindings = {
      "Mod1+p" = lib.mkForce "exec wofi --show run";
    };
  };

  # Waybar widgets position and battery
  programs.waybar = {
    settings.mainBar = {
      # Waybar widget to show work VPN connectivity
      "custom/vpn".exec = builtins.readFile ./configs/vpn-check.sh;
      # Waybar widget to show SSH and Kerberos state
      "custom/access".exec =
        (pkgs.writeShellScriptBin "access"
          (builtins.readFile ./configs/access.sh))
        + "/bin/access";

      modules-right = lib.mkForce [
        "custom/access"
        "battery"
        "pulseaudio"
        "network"
        "custom/vpn"
        "sway/language"
        "custom/suspend"
        "tray"
      ];

      "battery" = {
        bat = "BAT0";
        interval = 60;
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{capacity}% {icon}";
        #format-icons = {
        #default = ["", "", "", "", "", "", ""];
        #};
        max-length = 25;
      };
    };
  };

  # Prevent Firefox from querying Nitrokey
  #
  # Firefox is setup to query Smart Cards and for that reason it talks to
  # Nitrokey every time you open a new tab. It slows down the browser
  # considerably almost to the point it's unusable.
  home.file = {
    ".config/pkcs11/modules/opensc.module" = {
      source = ./configs/opensc.module;
    };
  };
}
