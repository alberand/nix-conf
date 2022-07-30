# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.loader = {
    efi = {
	# canTouchEfiVariables = true;
	efiSysMountPoint = "/boot/efi";
    };
    grub = {
	enable = true;
	version = 2;
	efiInstallAsRemovable = true;
	efiSupport = true;
	devices = ["nodev"];
    };
  };

  # Vulkan API/OpenCL API/Modern AMD Graphics Core Next (GCN) GPUs
  hardware.opengl.extraPackages = with pkgs; [
	rocm-opencl-icd
	amdvlk
  ];

  system.autoUpgrade = { 
	enable = true;
  	allowReboot = false;
  	channel = https://nixos.org/channels/nixos-unstable;
  };

  
  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=30 # Don't block reboot for too long
    '';
  };

  programs.sway = {
	enable = true;
	extraPackages = with pkgs; [
      		swaylock
      		wl-clipboard
      		mako
		kitty
		waybar
		font-awesome
		wofi
	];
  };
  programs.waybar.enable = true;

  networking.hostName = "nixxy"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  # networking.defaultGateway = "192.168.0.1";
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
  networking.interfaces.enp1s0.useDHCP = true;

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

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # services.flatpak.enable = true;

  environment.variables.EDITOR = "vim";

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alberand = {
    isNormalUser = true;
    description = "It's me. I found myself here.";
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
    wget
    kitty
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

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

  programs.zsh.enable = true;

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


  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };
}

