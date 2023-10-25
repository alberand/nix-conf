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
  };
  services.mbsync.configFile = ./configs/.mbsyncrc;
  services.mbsync.postExec = "${pkgs.bash}/bin/sh ${config.home.homeDirectory}/.redhat/notmuch-hook.sh";

  programs.gpg = {
    enable = true;
  };

  # Script to check work VPN connectivity
  programs.waybar.settings.mainBar."custom/vpn".exec =
    (builtins.readFile ./configs/vpn-check.sh);

  wayland.windowManager.sway.config = {
    startup = [
      { command = "swaymsg 'workspace 1; exec firefox'"; }
      { command = "swaymsg 'workspace 2; exec kitty'"; }
      { command = "swaymsg 'exec \"sleep 1; flameshot\"'"; }
    ];
  };
}
