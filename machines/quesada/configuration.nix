{
  modulesPath,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
      };
    };
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "sr_mod"
      "virtio_blk"
    ];
    kernelParams = [
      "console=tty1"
      "console=ttyS0,115200"
    ];
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.zsh
    pkgs.firefox
    pkgs.networkmanager
  ];

  networking = {
    useDHCP = true;
    networkmanager.enable = false;
    hostName = "quesada";
    nameservers = [
      "194.242.2.9" # Mullvad
      "1.1.1.1"
      "8.8.8.8"
    ];
    firewall = {
      enable = true;
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  services.journald.extraConfig = ''
    SystemMaxUse=100M
    MaxFileSec=7day
  '';

  services.ntp.enable = true;
  services.automatic-timezoned.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  programs.zsh.enable = true;
  users.users.alberand = {
    isNormalUser = true;
    description = "alberand";
    uid = 1000;
    shell = pkgs.zsh;
    hashedPassword = "$6$sDIm5DtPaJyCyq9e$WnjbB10099NocG7Lg4BdzkU9OnJuZpWhKFuY/WpL.pytKdfNsZldK5iitnG5VF32u3WyeuE6PbZ.1xdtFDocx0";
    extraGroups = [
      "wheel"
      "sudo"
      "networkmanager"
      "disk"
    ];
  };

  users.users.alberand.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsaaX1d/7zZHiZIsPFhtvmEChTB0p7sKECk7p6UcUqr andrey.albershteyn@gmail.com"
  ];
  services.openssh.settings.AllowUsers = ["alberand"];

  age.secrets.tailscale.file = ../../secrets/quesada-tskey.age;
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.age.secrets.tailscale.path;
  };

  services = {
    xserver.desktopManager.plasma5.bigscreen.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };

  services.displayManager.sddm.settings = {
    Autologin = {
      Session = "plasma";
      User = "alberand";
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = ["alberand"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    optimise.automatic = true;
  };

  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
  };

  system.stateVersion = "25.05";
}
