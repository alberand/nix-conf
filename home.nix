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
		cargo
		glibc
		gimp
		inkscape
		# clang
		# clang-tools
		python3

		# Emails
		thunderbird
		isync
		notmuch

		# Media
		vlc
		jellyfin

		# work
		#  linux
		xfstests
		b4
		getopt
		flex
		bison
		# Cannot be used together with clang
		gcc
		binutils
		perl
		gnumake
		bc
		pkg-config
		file
		gettext
		libtool
		automake
		autoconf
		libelf
		elfutils
		ncurses
		openssl
		zlib
		m4

		#   xfstests
		e2fsprogs
		attr
		acl
		libaio
		keyutils
		fsverity-utils
		ima-evm-utils
		util-linux
		stress-ng
		dbench
		xfsprogs
		fio
		linuxquota
		nvme-cli

		#   tools
		cscope
		patchutils_0_4_2

		# Games
		steam
		minecraft
		prismlauncher

		# Tools
		gnumake
		cmake
		wireshark
		gcc
		lsof
		rust-analyzer
	];

	imports = [
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
