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
			DefaultTimeoutStopSec=30
		'';
	};

	security.polkit.enable = true;
	systemd.user.services.waybar.enable = true;
	systemd.user.services.swayidle.enable = true;
	# systemd.user.services.kanshi = {
		# description = "Kanshi output autoconfig ";
		# wantedBy = [ "graphical-session.target" ];
		# partOf = [ "graphical-session.target" ];
		# serviceConfig = {
			# kanshi doesn't have an option to specifiy config file yet, so it looks
			# at .config/kanshi/config
			# ExecStart = ''
			# ${pkgs.kanshi}/bin/kanshi
			# '';
			# RestartSec = 5;
			# Restart = "always";
		# };
	# };

	fonts.fonts = with pkgs; [
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji
		fira-code
		fira-code-symbols
		inconsolata
		dina-font
		proggyfonts
		(nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "Inconsolata" ]; })
	];

	networking.hostName = "nixxy";
	# Pick only one of the below networking options.
	# networking.wireless.enable = true;
	networking.networkmanager.enable = true;
	networking.networkmanager.dns = "default";
	# networking.defaultGateway = "192.168.0.1";
	# networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
	# networking.nameservers = [ "10.64.156.60" ];
	networking.interfaces.enp34s0.useDHCP = true;
    # Route for wireguard VPN
    networking.interfaces.enp34s0.ipv4.routes = [{
      address = "185.195.233.66";
      prefixLength = 32;
      via = "192.168.0.1";
    }];
    # Temporary fix for https://github.com/NixOS/nixpkgs/issues/162260
    systemd.services.network-addresses-enp34s0 = {
      after = [ "dhcpcd.service" ];
    };

	# VPN configuration
	# Configure the NAT/Firewall
	networking.nat.enable = false;
	networking.nat.externalInterface = "enp34s0";
	networking.nat.internalInterfaces = [ "wg0" ];
	networking.firewall.enable = true;
	networking.firewall = {
		allowedTCPPorts = [ 53 ];
		allowedUDPPorts = [ 53 51820 ];
	};

	# Enable WireGuard
	networking.wireguard.interfaces = let
		server_ip = "185.195.233.66";
	in {
		wg0 = {
			# Determines the IP address and subnet of the client's
			# end of the tunnel interface.
			ips = [ "10.64.156.60/32" ];
			# to match firewall allowedUDPPorts (without this wg
			# uses random port numbers)
			listenPort = 51820;

            # postSetup = ''
                # ip route add ${server_ip} via 192.168.0.1 dev enp34s0
            # '';

            # postShutdown = ''
                # ip route del ${server_ip}
            # '';

			# Path to the private key file.
			privateKeyFile = "/etc/mullvad-vpn.key";

			peers = [{
				publicKey = "1493vtFUbIfSpQKRBki/1d0YgWIQwMV4AQAvGxjCNVM=";
				allowedIPs = [ "0.0.0.0/0" ];
				endpoint = "${server_ip}:51820";
				persistentKeepalive = 25;
			}];
		};
	};

	# DNS Server
    # services.dnsmasq = {
        # enable = true;
        # extraConfig = ''
            # interface=wg0
        # '';
    # };

	# Set your time zone.
	time.timeZone = "Europe/Prague";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
	# console = {
	#		font = "Lat2-Terminus16";
	#		keyMap = "us";
	#		useXkbConfig = true; # use xkbOptions in tty.
	# };

	environment.variables.EDITOR = "nvim";

	# Media group to access media storage
	users.groups.media = {
		name = "media";
		gid = 8096;
		members = [
			"alberand"
			"jellyfin"
		];
	};

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.alberand = {
		isNormalUser = true;
		description = "Andrey Albershteyn";
		extraGroups = [ "wheel" "sudo" "libvirt" "networkmanager" ];
		uid = 1000;
		shell = pkgs.zsh;
		packages = with pkgs; [
			firefox
			thunderbird
		];
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
        podman-compose

		# utils
		lshw
		pciutils
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

	# xdg-desktop-portal works by exposing a series of D-Bus interfaces
	# known as portals under a well-known name
	# (org.freedesktop.portal.Desktop) and object path
	# (/org/freedesktop/portal/desktop).  The portal interfaces include
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
	services.jellyfin.enable = true;

	services.grafana = {
		enable = true;
		port = 3000;
		addr = "127.0.0.1";
		analytics.reporting.enable = false;
	};

	services.nginx = {
		enable = true;
		virtualHosts.localhost = {
			listen = [{ 
				addr = "127.0.0.1"; 
			}];
			locations."/shared/" = {
				alias = "/srv/www/shared/";
			};
		};
	};


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

	virtualisation = {
		podman = {
			enable = true;
			# Create a `docker` alias for podman, to use it as a
			# drop-in replacement
			dockerCompat = true;
			# Required for containers under podman-compose to be
			# able to talk to each other.
			defaultNetwork.dnsname.enable = true;
		};
	};

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    "deluge" = {
      image = "binhex/arch-delugevpn";
      autoStart = false;
      ports = [ 
	    "8112:8112" 
	    "8118:8118" 
	    "58846:58846" 
	    "58946:58946" 
      ];
      volumes = [
	    "/media:/media"
	    "/home/alberand/.deluge:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        PUID = "1000";
        PGID = "100";
        VPN_ENABLED = "yes";
        VPN_CLIENT = "wireguard";
	    VPN_PROV = "custom";
        STRICT_PORT_FORWARD = "yes";
        ENABLE_PRIVOXY = "yes";
        LAN_NETWORK = "192.168.0.100/32";
        NAME_SERVERS = "84.200.69.80,37.235.1.174,1.1.1.1,37.235.1.177,84.200.70.40,1.0.0.1";
        DELUGE_DAEMON_LOG_LEVEL = "trace";
        DELUGE_WEB_LOG_LEVEL = "trace";
        DEBUG = "true";
        UMASK = "000";
        TZ = "Europe/London";
      };
      extraOptions = [
        "--privileged=true"
	    ''--sysctl="net.ipv4.conf.all.src_valid_mark=1"''
      ];
    };
  };

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "22.05"; # Did you read the comment?
}
