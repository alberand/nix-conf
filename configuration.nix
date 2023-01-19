{ config, pkgs, ... }:
let
	# bash script to let dbus know about important env variables and
	# propagate them to relevent services run at the end of sway config
	# see
	# https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
	# note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts	
	# some user services to make sure they have the correct environment variables
	dbus-sway-environment = pkgs.writeTextFile {
		name = "dbus-sway-environment";
		destination = "/bin/dbus-sway-environment";
		executable = true;

		text = ''
	dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
	systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
	systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
			'';
	};

	# currently, there is some friction between sway and gtk:
	# https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
	# the suggested way to set gtk settings is with gsettings
	# for gsettings to work, we need to tell it where the schemas are
	# using the XDG_DATA_DIR environment variable
	# run at the end of sway config
	configure-gtk = pkgs.writeTextFile {
			name = "configure-gtk";
			destination = "/bin/configure-gtk";
			executable = true;
			text = let
	schema = pkgs.gsettings-desktop-schemas;
	datadir = "${schema}/share/gsettings-schemas/${schema.name}";
			in ''
	export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
	gnome_schema=org.gnome.desktop.interface
	gsettings set $gnome_schema gtk-theme 'Dracula'
	'';
	};

in
{
	imports = [
		./hardware-configuration.nix
		./modules/wireguard.nix
		./modules/podman-deluge.nix
		./modules/nginx.nix
		./modules/grafana.nix
		./modules/tmux.nix
	];

	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = false;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.loader = {
		grub = {
			enable = true;
			version = 2;
			efiSupport = true;
			enableCryptodisk = true;
			device = "nodev";
		};
	};
	boot.initrd.luks.devices = {
		crypted = {
			device = "/dev/disk/by-uuid/4e62f0f4-6b77-4947-b031-c7d5652a8eb3";
			preLVM = true;
		};
	};
	boot.initrd.kernelModules = [ "amdgpu" ];

	# Vulkan API/OpenCL API/Modern AMD Graphics Core Next (GCN) GPUs
	hardware.opengl.enable = true;
	hardware.opengl.driSupport = true;
	hardware.opengl.driSupport32Bit = true;
	hardware.opengl.extraPackages = with pkgs; [
		rocm-opencl-icd
		rocm-opencl-runtime
		amdvlk
	];

	environment.sessionVariables = rec {
		XDG_CACHE_HOME	= "\${HOME}/.cache";
		XDG_CONFIG_HOME = "\${HOME}/.config";
		XDG_BIN_HOME = "\${HOME}/.local/bin";
		XDG_DATA_HOME = "\${HOME}/.local/share";

		PATH = [ 
			"\${XDG_BIN_HOME}"
		];
	};

	systemd = {
		extraConfig = ''
			DefaultTimeoutStopSec=30s
		'';
	};

	security.polkit.enable = true;
	systemd.user.services.waybar.enable = true;
	systemd.user.services.swayidle.enable = true;
    systemd.user.services.kanshi = {
        description = "kanshi daemon";
        serviceConfig = {
            Type = "simple";
            ExecStart = ''${pkgs.kanshi}/bin/kanshi'';
            RestartSec = 5;
            Restart = "always";
        };
    };

	fonts.fonts = with pkgs; [
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji
		fira-code
		fira-code-symbols
		inconsolata
		dina-font
		proggyfonts
		(nerdfonts.override {
			fonts = ["FiraCode" "DroidSansMono" "Inconsolata" ]; })
	];

	networking.hostName = "nixxy";
	# Pick only one of the below networking options.
	networking.networkmanager.enable = true;
	networking.networkmanager.dns = "default";
	networking.defaultGateway = "192.168.0.1";
	# networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
	networking.interfaces.enp34s0.useDHCP = true;
	# VPN configuration
	# Configure the NAT/Firewall
	networking.firewall.enable = true;
	# TODO not sure what it is but Tailscale wants it
	networking.firewall.checkReversePath = "loose";
	networking.firewall = {
		allowedTCPPorts = [ 53 22 8384 22000 ];
		allowedUDPPorts = [ 53 51820 22000 21027];
	};

	# Set your time zone.
	time.timeZone = "Europe/Prague";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
	console = {
			font = "Lat2-Terminus16";
			keyMap = "us";
	};

	environment.variables.EDITOR = "nvim";

	# Media group to access media storage
	users.groups.media = {
		name = "media";
		gid = 8096;
		members = [
			"alberand"
			"jellyfin"
            "deluge"
		];
	};

	users.users.deluge = {
		isNormalUser = true;
		description = "Deluge";
		extraGroups = [ "media" ];
		uid = 1002;
	};

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.alberand = {
		isNormalUser = true;
		description = "Andrey Albershteyn";
        extraGroups = [ 
          "wheel" 
          "sudo" 
          "libvirt" 
          "networkmanager" 
          "wireshark" 
          "disk" 
        ];
		uid = 1000;
		shell = pkgs.zsh;
	};

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		htop
		vim
		neovim
		wget
		kitty
		git
		wireguard-tools
		unzip
		zsh
		gdb
		tmux
		mc
        fzf

		# utils
		lshw
		pciutils
        ntfs3g

        # work
        qemu_full
        qemu-utils
        # xfstests

        # video
        mesa
        mesa-demos
        vulkan-tools
        radeontop
        libgdiplus
        wine
        wine-wayland

        # Photos
        # photoprism
	];

	# Enable sound.
	sound.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		# If you want to use JACK applications, uncomment this
		#jack.enable = true;
	};

    users.groups.wireshark.gid = 500;
    security.wrappers.dumpcap = {
      source = "${pkgs.wireshark}/bin/dumpcap";
      permissions = "u+xs,g+x";
      owner = "root";
      group = "wireshark";
    };

	# xdg-desktop-portal works by exposing a series of D-Bus interfaces
	# known as portals under a well-known name
	# (org.freedesktop.portal.Desktop) and object path
	# (/org/freedesktop/portal/desktop). The portal interfaces include
	# APIs for file access, opening URIs, printing and others.
	services.dbus.enable = true;
	xdg.portal = {
		enable = true;
		wlr.enable = true;
		# gtk portal needed to make gtk apps happy
		extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
	};

	# Enable WeeChat to run as service with attached 'screen' session To
	# attach use: screen -x weechat/wc
	services.weechat.enable = true;
	services.weechat.sessionName = "wc";
	programs.screen.screenrc = ''
		multiuser on
		acladd normal_user
	'';

	# Enable the OpenSSH daemon.
	services.openssh = {
		enable = true;
		forwardX11 = true;
	};

	programs.ssh = {
		startAgent = true;
		agentTimeout = "24h";
	};

	programs.gnupg.agent.enable = false;
	security.rtkit.enable = true;
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

	virtualisation = {
        oci-containers.backend = "podman";
		podman = {
			enable = true;
			# Create a `docker` alias for podman, to use it as a
			# drop-in replacement
			dockerCompat = true;
		};
	};

    programs.kdeconnect.enable = true;

    services = {
        syncthing = {
          enable = true;
          dataDir = "/home/alberand/Share";
          configDir = "/home/alberand/.config/syncthing";
          # overrides any devices added or deleted through the WebUI
          overrideDevices = true;
          # overrides any folders added or deleted through the WebUI
          overrideFolders = true;
          user = "alberand";
          group = "users";
          devices = {
            "lonmoun" = {
              id = "BHZVVJE-BKYAHGR-6ET6T2T-O7SRFSC-AKQEOP3-KYR4JME-ARSWMAB-HQSRBQL";
            };
            "nothing-phone" = {
              id = "74LMGV3-VGBB6J7-CT7LRHY-CANX5WF-UOVYYXG-762UH5M-6HFZKLB-AXNP2QW";
            };
          };
          folders = {
            "Documents" = {        # Name of folder in Syncthing, also the folder ID
              path = "/home/alberand/Share/Documents";    # Which folder to add to Syncthing
              devices = [ "lonmoun" "nothing-phone" ];      # Which devices to share the folder with
            };
            "Photos" = {        # Name of folder in Syncthing, also the folder ID
              path = "/home/alberand/Share/Photos";    # Which folder to add to Syncthing
              devices = [ "lonmoun" "nothing-phone" ];      # Which devices to share the folder with
            };
          };
        };
    };

    #services.photoprism = {
      #enable = true;
      #port = 8200;
      #originalsPath = "/home/alberand/Share/Photos";
    #};

	nix = {
		settings.auto-optimise-store = true;
		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than 7d";
		};
		package = pkgs.nixVersions.unstable;
		extraOptions = ''
			experimental-features = nix-command flakes
			keep-outputs = true
			keep-derivations = true
		'';
	};

	system.autoUpgrade = { 
		enable = true;
		allowReboot = false;
		channel = https://nixos.org/channels/nixos-unstable;
	};

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "22.11"; # Did you read the comment?
}
