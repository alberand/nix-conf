{
  config,
  pkgs,
  lib,
  ...
}: let
  domain = "door.alberand.com";
  # TODO
  public_ip = "";
in {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    # ((import ./headscale.nix) {inherit domain public_ip;})
    # ((import ./dns.nix) {inherit domain public_ip;})
  ];

  fileSystems."/persistent".neededForBoot = true;

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
      };
    };
    kernelParams = [
      "console=tty1"
      "console=ttyS0,115200"
    ];
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
      ];
      postResumeCommands = lib.mkAfter ''
        mkdir /btrfs_tmp
        mount /dev/root_vg/root /btrfs_tmp
        if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
        }

        for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
            delete_subvolume_recursively "$i"
        done

        btrfs subvolume create /btrfs_tmp/root
        umount /btrfs_tmp
      '';
    };
  };

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
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "eth0";
    };
    networkmanager.unmanaged = ["interface-name:ve-*"];
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
      LogLevel = "DEBUG3";
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  programs.zsh.enable = true;
  users.users.alberand = {
    isNormalUser = true;
    description = "alberand";
    uid = 1000;
    shell = pkgs.zsh;
    home = "/home/alberand";
    hashedPassword = "$6$sDIm5DtPaJyCyq9e$WnjbB10099NocG7Lg4BdzkU9OnJuZpWhKFuY/WpL.pytKdfNsZldK5iitnG5VF32u3WyeuE6PbZ.1xdtFDocx0";
    extraGroups = [
      "wheel"
      "sudo"
      "networkmanager"
      "disk"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsaaX1d/7zZHiZIsPFhtvmEChTB0p7sKECk7p6UcUqr"
    ];
  };

  services.openssh.settings.AllowUsers = ["alberand"];

  environment.systemPackages = with pkgs; [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.zsh
  ];

  system.stateVersion = "25.05";
}
