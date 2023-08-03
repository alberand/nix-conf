{ config, pkgs, ... }: {
  imports = [
    ../../modules/common.nix
    ../../modules/tmux.nix
    ../../modules/work-vpn.nix
  ];

  # Use the systemd-boot EFI boot loader.
  #boot.loader = {
  #  systemd-boot.enable = false;
  #  efi.canTouchEfiVariables = true;
  #  grub = {
  #    enable = true;
  #    efiSupport = true;
  #    enableCryptodisk = true;
  #    device = "nodev";
  #  };
  #};

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  #boot.initrd.luks.devices = {
  #  crypted = {
  #    device = "/dev/disk/by-uuid/4e62f0f4-6b77-4947-b031-c7d5652a8eb3";
  #    preLVM = true;
  #  };
  #};

  #networking = {
  #  hostName = "thinky";
  #  # Pick only one of the below networking options.
  #  networkmanager.enable = true;
  #  networkmanager.dns = "default";
  #  defaultGateway = "192.168.0.1";
  #  # nameservers = [ "8.8.8.8" "1.1.1.1" ];
  #  interfaces.enp34s0.useDHCP = true;
  #  # VPN configuration
  #  # Configure the NAT/Firewall
  #  firewall.enable = true;
  #  # TODO not sure what it is but Tailscale wants it
  #  firewall.checkReversePath = "loose";
  #  firewall = {
  #    allowedTCPPorts = [ 53 22 ];
  #    allowedUDPPorts = [ 53 ];
  #  };
  #};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alberand = {
    isNormalUser = true;
    description = "Andrey Albershteyn";
    uid = 1000;
    shell = pkgs.zsh;
    group = "users";
    extraGroups = [
      "wheel"
      "sudo"
      "libvirt"
      "networkmanager"
      "disk"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wayland
    xdg-utils # for opening default programs when clicking links
    swaylock
    swayidle
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    bemenu # wayland clone of dmenu
    mako # notification system developed by swaywm maintainer
    wdisplays # tool to configure displays
  ];

  # Enable sound.
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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

  security.rtkit.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
