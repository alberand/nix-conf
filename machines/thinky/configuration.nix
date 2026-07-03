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

    users.groups.aalbersh = {
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

    environment.systemPackages = with pkgs; [
      wdisplays # tool to configure displays
    ];

    environment.variables = {
      REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
      NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
    };

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
    system.stateVersion = "26.05"; # Did you read the comment?
  };
}
