{ config, pkgs, lib, ... }: {
  imports = [
    ../../modules/home-base.nix
    ../../modules/neomutt.nix
    ../../modules/kanshi.nix
  ];

  home.username = "aalbersh";
  home.homeDirectory = "/home/aalbersh";

  home.packages = with pkgs; [
    cargo
    rust-analyzer
    wireshark
    pinentry
    (writeShellScriptBin "git-bp" (builtins.readFile ./configs/git-bp))
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
    ".shrc.local" = {
      source = ./configs/.shrc.local;
    };
  };
  services.mbsync.configFile = ./configs/.mbsyncrc;
  services.mbsync.postExec = "${pkgs.bash}/bin/sh ${config.home.homeDirectory}/.redhat/notmuch-hook.sh";

  programs.gpg = {
    enable = true;
  };

  wayland.windowManager.sway.config = {
    startup = [
      { command = "swaymsg 'workspace 1; exec firefox'"; }
      { command = "swaymsg 'workspace 2; exec kitty'"; }
      { command = "swaymsg 'exec \"sleep 1; flameshot\"'"; }
    ];
  };
}
