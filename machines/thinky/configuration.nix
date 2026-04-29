{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../options.nix
    ../../modules/common.nix
    ../../modules/work-vpn.nix
    ../../modules/kerberos.nix
    ../../modules/qemu-guest-network.nix
    ../../modules/proxy.nix
    ../../modules/builders.nix
    ../../modules/tailscale.nix
    ../../modules/nitrokey.nix
  ];

  config = {
    user = "aalbersh";

    boot.loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
      };
    };

    boot.initrd.luks.devices = {
      nixos = {
        device = "/dev/disk/by-uuid/f5f202c5-f8e5-47cd-8768-b719e339e241";
        preLVM = true;
      };
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [vaapiIntel];

    networking = {
      hostName = "thinky";
      # Pick only one of the below networking options.
      networkmanager.enable = true;
      networkmanager.dns = "systemd-resolved";
      # VPN configuration
      # Configure the NAT/Firewall
      firewall.enable = true;
      firewall = {
        allowedTCPPorts = [
          53 # dns
          782 # conserver
          443 # https
          853 # DNS over TLS
        ];
        allowedUDPPorts = [
          53 # dns
          782 # conserver
          443 # https
          853 # DNS over TLS
        ];
      };
    };

    services.resolved = {
      enable = true;
      dnssec = "true";
      domains = ["~."];
      fallbackDns = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1"
      ];
      extraConfig = ''
        DNSOverTLS=no
      '';
    };

    services.openssh.settings.AllowUsers = ["aalbersh"];

    users.groups.aalbersh ={
      gid = 1000;
      members = ["aalbersh"];
    };
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.aalbersh = {
      isNormalUser = true;
      description = "Andrey Albershteyn";
      uid = 1000;
      shell = pkgs.zsh;
      extraGroups = [
        "aalbersh"
        "wheel"
        "sudo"
        "libvirtd"
        "networkmanager"
        "disk"
        "wireshark"
        "dialout"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTyoIDtgjlNfutIx2mL1rcJgTgy2xPtBE658NMuEKxy"
      ];
    };

    # Enable 'sudo' with SSH key
    security.pam.sshAgentAuth = {
      enable = true;
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      bemenu # wayland clone of dmenu
      mako # notification system developed by swaywm maintainer
      wdisplays # tool to configure displays
      revumatic
      koji
      claude
    ];

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

    # fileSystems."/mnt/lonmoun" = {
    #   device = "192.168.0.100:/alberand";
    #   fsType = "nfs";
    #   options = [
    #     "noauto"
    #     "x-systemd.automount"
    #     "nofail"
    #     "x-systemd.mount-timeout=5s"
    #   ];
    # };

    programs.firefox = {
      enable = true;
      preferences = {
        "network.negotiate-auth.trusted-uris" = ".redhat.com";
      };
    };

    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?
  };
}
