# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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
  imports =
    [ # Include the results of the hardware scan.
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
  # boot.extraModprobeConfig = "options kvm_intel nested=1";
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

  system.autoUpgrade = { 
	enable = true;
  	allowReboot = false;
  	channel = https://nixos.org/channels/nixos-unstable;
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME    = "\${HOME}/.local/bin";
    XDG_DATA_HOME   = "\${HOME}/.local/share";

    PATH = [ 
      "\${XDG_BIN_HOME}"
    ];
  };

  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=30 # Don't block reboot for too long
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

  services.jellyfin.enable = true;

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

  networking.hostName = "nixxy"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  # networking.defaultGateway = "192.168.0.1";
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
  networking.interfaces.enp34s0.useDHCP = true;

  	# VPN configuration
	# Configure the NAT/Firewall
  	networking.nat.enable = true;
  	networking.nat.externalInterface = "enp34s0";
  	networking.nat.internalInterfaces = [ "wg0" ];
  	networking.firewall.enable = true;
  	networking.firewall = {
    		allowedTCPPorts = [ 53 ];
    		allowedUDPPorts = [ 53 51820 ];
  	};

  # Enable WireGuard
  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "10.64.156.60/32" ];
      listenPort = 51820; # to match firewall allowedUDPPorts (without this wg
	# uses random port numbers)

	# This allows the wireguard server to route your traffic to the internet and hence be like a VPN
    # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.64.156.60/32 -o enp34s0 -j MASQUERADE
    '';

    # This undoes the above command
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.64.156.60/32 -o enp34s0 -j MASQUERADE
    '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/etc/mullvad-vpn.key";

	peers = [
        # For a client configuration, one peer entry for the server will suffice.
        {
          # Public key of the server (not a file path).
          publicKey = "1493vtFUbIfSpQKRBki/1d0YgWIQwMV4AQAvGxjCNVM=";

          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          # For a server peer this should be the whole subnet.
          allowedIPs = [ "0.0.0.0/0" ];

          # Set this to the server IP and port.
          endpoint = "185.195.233.66:51820";

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };

	# DNS Server
  services.dnsmasq = {
    enable = true;
    extraConfig = ''
      interface=wg0
    '';
  };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  environment.variables.EDITOR = "nvim";

  services.grafana = {
	enable = true;
	port = 3000;
	addr = "127.0.0.1";
	analytics.reporting.enable = false;
  };

  services.nginx = {
	enable = true;
	virtualHosts.localhost = {
  		listen = [{ addr = "127.0.0.1"; }];
  		locations."/shared/" = {
    			alias = "/srv/www/shared/";
  		};
	};
  };

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
    extraGroups = [ "wheel" "sudo" "docker" "libvirt" "networkmanager" ];
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

    # utils
    lshw
    pciutils
  ];

  security.rtkit.enable = true;

  # Enable sound.
  sound.enable = true;
  # hardware.pulseaudio.enable = true;
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
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable WeeChat to run as service with attached 'screen' session
  # To attach use: screen -x weechat/wc
  services.weechat.enable = true;
  services.weechat.sessionName = "wc";
  programs.screen.screenrc = ''
    multiuser on
    acladd normal_user
  '';

  programs.ssh.startAgent = true;


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  nix = {
	  settings.auto-optimise-store = true;
	  gc = {
	  	automatic = true;
	  	dates = "weekly";
	  	options = "--delete-older-than 7d";
	  };
    package = pkgs.nixVersions.unstable;    # Enable nixFlakes on system
    # registry.nixpkgs.flake = pkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  # virtualisation.lxd.enable = true;
  # virtualisation.lxc.lxcfs.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}

