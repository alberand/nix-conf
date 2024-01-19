{ config, pkgs, lib, ... }: {
  imports = [
    ../../modules/home-base.nix
    ../../modules/neomutt.nix
    ../../modules/kanshi.nix
    ../../modules/redhat-beaker.nix
  ];

  home.username = "aalbersh";
  home.homeDirectory = "/home/aalbersh";

  home.packages = with pkgs; [
    cargo
    rust-analyzer
    pinentry
    conserver
    (let
        wrapper = (writeShellScriptBin "con" (builtins.readFile ./configs/console.sh));
    in pkgs.symlinkJoin {
      name = "conserver";
      paths = [
        conserver
        wrapper
      ];
    })
    (writeShellScriptBin "git-bp" (builtins.readFile ./configs/git-bp))
    (writeShellScriptBin "machine" (builtins.readFile ./configs/machine))
  ];

  home.file = {
    ".muttrc.local" = {
      source = ./configs/.muttrc.local;
    };
    ".notmuch-config" = {
      source = ./configs/.notmuch-config;
    };
    ".redhat/notmuch-hook.sh" = {
      source = ./configs/notmuch-hook.sh;
    };
    ".redhat/neomutt-jira.sh" = {
      source = ./configs/neomutt-jira.sh;
    };
    ".shrc.local" = {
      source = ./configs/.shrc.local;
    };
    ".consolerc" = {
      source = ./configs/.consolerc;
    };
  };
  services.mbsync.configFile = ./configs/.mbsyncrc;
  services.mbsync.postExec = "${pkgs.bash}/bin/sh ${config.home.homeDirectory}/.redhat/notmuch-hook.sh";

  programs.gpg = {
    enable = true;
  };

  # Script to check work VPN connectivity
  programs.waybar.settings.mainBar."custom/vpn".exec =
    (builtins.readFile ./configs/vpn-check.sh);

  programs.waybar.settings.mainBar."custom/access".exec =
    (pkgs.writeShellScriptBin "access" (builtins.readFile ./configs/access.sh)) + "/bin/access";

  wayland.windowManager.sway.config = {
    startup = [
      { command = "swaymsg 'workspace 1; exec firefox'"; }
      { command = "swaymsg 'workspace 2; exec kitty'"; }
      { command = "swaymsg 'exec \"sleep 1; flameshot\"'"; }
    ];
  };

  programs.waybar.settings.mainBar = {
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
}
