{ config, pkgs, lib, ... }: {
  imports = [
    ../../modules/home-base.nix
  ];

  home.username = "aalbersh";
  home.homeDirectory = "/home/aalbersh";

  home.packages = with pkgs; [
    cargo
    rust-analyzer
    wireshark
    terminator
  ];

  wayland.windowManager.sway.config = {
    startup = [
      { command = "swaymsg 'workspace 1; exec firefox'"; }
      { command = "swaymsg 'workspace 2; exec kitty'"; }
      { command = "swaymsg 'workspace 2; exec terminator'"; }
      { command = "swaymsg 'exec \"sleep 1; flameshot\"'"; }
    ];
  };
}
