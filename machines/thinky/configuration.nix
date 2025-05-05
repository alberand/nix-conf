{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../options.nix
    ../../modules/common.nix
    ../../modules/work-vpn.nix
    ../../modules/kerberos.nix
    ../../modules/qemu-guest-network.nix
    ../../modules/mysql.nix
    ../../modules/squid.nix
    ../../modules/builders.nix
    ../../modules/tailscale.nix
  ];

  config = {
    user = "aalbersh";

    # Use the systemd-boot EFI boot loader.
    boot.loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        #enableCryptodisk = true;
        device = "nodev";
      };
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [vaapiIntel];

    boot.initrd.luks.devices = {
      nixos = {
        device = "/dev/disk/by-uuid/f5f202c5-f8e5-47cd-8768-b719e339e241";
        preLVM = true;
      };
    };

    services.resolved = {
      enable = true;
      dnssec = "true";
      domains = ["~."];
      fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
      extraConfig = ''
        DNSOverTLS=no
      '';
    };

    networking = {
      hostName = "thinky";
      # Pick only one of the below networking options.
      networkmanager.enable = true;
      networkmanager.dns = "systemd-resolved";
      #defaultGateway = "192.168.0.1";
      #nameservers = [ "8.8.8.8" "1.1.1.1" ];
      # interfaces.enp0s20f0u3.useDHCP = true;
      # VPN configuration
      # Configure the NAT/Firewall
      firewall.enable = true;
      firewall = {
        allowedTCPPorts = [
          53 # dns
          22 # ssh
          88 # kerberos
          782 # conserver
          443 # https
          853 # DNS over TLS
          1194 # openvpn
          config.services.squid.proxyPort
        ];
        allowedUDPPorts = [
          53 # dns
          88 # kerberos
          782 # conserver
          443 # https
          853 # DNS over TLS
          1194 # openvpn
        ];
      };
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.aalbersh = {
      isNormalUser = true;
      description = "Andrey Albershteyn";
      uid = 1000;
      shell = pkgs.zsh;
      group = "users";
      extraGroups = ["wheel" "sudo" "libvirtd" "networkmanager" "disk" "wireshark"];
    };

    users.users.ktest = {
      isNormalUser = true;
      description = "Andrey Albershteyn";
      uid = 4207372;
      shell = pkgs.zsh;
      group = "users";
      extraGroups = ["wheel" "sudo" "libvirt" "networkmanager" "disk" "wireshark"];
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      wayland
      xdg-utils # for opening default programs when clicking links
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      bemenu # wayland clone of dmenu
      mako # notification system developed by swaywm maintainer
      wdisplays # tool to configure displays
      revumatic
      koji
      nbd
    ];

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
      config = {common = {default = ["gtk"];};};
      # gtk portal needed to make gtk apps happy
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    # Enable WeeChat to run as service with attached 'screen' session To
    # attach use: screen -x weechat/wc
    nixpkgs.overlays = [
      (self: super: {
        weechat = super.weechat.override {
          configure = {availablePlugins, ...}: {
            scripts = with super.weechatScripts; [
              weechat-autosort
              weechat-notify-send
              weechat-go
              wee-slack
            ];
          };
        };
      })
    ];

    fileSystems."/mnt/lonmoun" = {
      device = "192.168.0.100:/alberand";
      fsType = "nfs";
      options = ["x-systemd.mount-timeout=5s"];
    };

    # pipewire needs it
    security.rtkit.enable = true;

    systemd.user.services.kanshi = {
      enable = true;
      description = "Kanshi daemon (monitor configurator)";
      wantedBy = [];
      after = [];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kanshi}/bin/kanshi -c kanshi_config_file";
      };
    };

    virtualisation.libvirtd.enable = true;

    programs.firefox = {
      enable = true;
      preferences = {
        "network.negotiate-auth.trusted-uris" = ".redhat.com";
      };
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.11"; # Did you read the comment?
  };
}
