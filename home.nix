{ config, pkgs, ... }:

{
  home.username = "alberand";
  home.homeDirectory = "/home/alberand";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

	home.packages = with pkgs; [ 
		htop 
		neomutt
		flameshot
		thunderbird
		gdb
		tmux
		isync
		notmuch
		cmst
		tdesktop
		mc
		zathura
		zsh
		feh
		steam
		swaylock
		wl-clipboard
		mako
		kitty
		waybar
		font-awesome
		wofi
		bemenu
	];

	imports =
	[
		./modules/nvim.nix
		./modules/sway.nix
	];

  home.file = {
    ".ctags" = {
      source = ./.ctags;
    };
    ".gdbinit" = {
      source = ./.gdbinit;
    };
    ".gitconfig" = {
      source = ./.gitconfig;
    };
    ".gitignore" = {
      source = ./.gitignore;
    };
    ".mbsyncrc" = {
      source = ./.mbsyncrc;
    };
    ".muttrc" = {
      source = ./.muttrc;
    };
    ".shrc.local" = {
      source = ./.shrc.local;
    };
    ".tmux.conf" = {
      source = ./.tmux.conf;
    };
    ".zshrc" = {
      source = ./.zshrc;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 1800;
  };

}
