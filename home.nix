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
	home.stateVersion = "22.11";

	# Let Home Manager install and manage itself.
	programs.home-manager.enable = true;

	home.packages = with pkgs; [ 
        # System
		neomutt
		flameshot
		firefox
		thunderbird
		isync
		notmuch
		cmst
		tdesktop
		swaylock
		wl-clipboard
		mako
		kitty
		waybar
		font-awesome
		wofi
		bemenu
		tdesktop
		alacritty
		foot
		zathura
		feh

        # Media
        vlc
		jellyfin

        # work
        xfstests
        b4

        # Games
		steam
        minecraft
        prismlauncher

        # Tools
        gnumake
        cmake
        wireshark
        gcc
	];

	imports =
	[
		./modules/nvim.nix
		./modules/sway.nix
		./modules/waybar.nix
		./modules/zsh.nix
		./modules/mako.nix
		./modules/wofi.nix
	];

    home.file = {
      ".ctags" = { source = ./.ctags; };
      ".gdbinit" = { source = ./.gdbinit; };
      ".gitconfig" = { source = ./.gitconfig; };
      ".gitignore" = { source = ./.gitignore; };
      ".mbsyncrc" = { source = ./.mbsyncrc; };
      ".muttrc" = { source = ./.muttrc; };
      ".shrc.local" = { source = ./.shrc.local; };
      ".vimrc.local" = { source = ./.vimrc.local; };
    };

	services.gpg-agent = {
  		enable = true;
  		enableSshSupport = true;
  		defaultCacheTtl = 1800;
	};
}
