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
    terminator
    pinentry
  ];

  home.file = {
    ".muttrc.local" = {
      source = ./configs/.muttrc.local;
    };
    ".notmuch-config" = {
      source = ./configs/.notmuch-config;
    };
    ".mbsyncrc" = {
      source = ./configs/.mbsyncrc;
    };
    ".shrc.local" = {
      source = ./configs/.shrc.local;
    };
  };

  programs.gpg = {
    enable = true;
  };

  wayland.windowManager.sway.config = {
    startup = [
      { command = "swaymsg 'workspace 1; exec firefox'"; }
      { command = "swaymsg 'workspace 2; exec kitty'"; }
      { command = "swaymsg 'workspace 2; exec terminator'"; }
      { command = "swaymsg 'exec \"sleep 1; flameshot\"'"; }
    ];
  };
}
