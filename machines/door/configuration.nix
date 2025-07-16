{
  config,
  pkgs,
  lib,
  ...
}: let
  domain = "door.alberand.com";
  public_ip = "77.90.6.241";
in {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ((import ./headscale.nix) {inherit domain public_ip;})
    ((import ./dns.nix) {inherit domain public_ip;})
    ./pocket-id.nix
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
    hostName = "door";
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = public_ip;
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "77.90.6.1";
      interface = "ens3";
    };

    nameservers = [
      "127.0.0.1"
    ];
    firewall = {
      enable = true;
      allowedTCPPorts = [80 443];
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
      {
        path = "/persistent/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

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

  environment.systemPackages = [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.zsh
    pkgs.util-linux
    pkgs.busybox
  ];

  systemd.services.tailscaled-autoconnect.after = ["network-online.service"];

  environment.persistence."/persistent" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/headscale"
      "/var/run/headscale"
      "/var/lib/systemd/coredump"
      "/var/lib/pocket-id"
      "/etc/headscale"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      # machine-id is used by systemd for the journal, to see previous boots
      "/etc/machine-id"
      {
        file = "/etc/ssh/ssh_host_ed25519_key";
        parentDirectory = {mode = "u=rwx,g=,o=";};
      }
      {
        file = "/etc/ssh/ssh_host_ed25519_key.pub";
        parentDirectory = {mode = "u=rwx,g=,o=";};
      }
    ];
    users.alberand = {
      directories = [
        {
          directory = ".ssh";
          mode = "0700";
        }
      ];
      files = [
        {
          file = ".zshrc";
        }
      ];
    };
  };

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
    };

    shellInit = ''
      # Uncomment the following line to enable command auto-correction.
      ENABLE_CORRECTION="true"

      # Uncomment the following line to display red dots whilst waiting for completion.
      COMPLETION_WAITING_DOTS="true"

      # Without this zsh will echo entered command
      DISABLE_AUTO_TITLE="true"

      # Uncomment the following line if you want to change the command execution time
      # stamp shown in the history command output.
      # The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
      HIST_STAMPS="dd.mm.yyyy"

      # Locale
      export LC_ALL=en_US.UTF-8
      export LANG=en_US.UTF-8
      export LANGUAGE=en_US.UTF-8

      export TERM=screen-256color
      export VISUAL="nvim"
      export EDITOR="nvim"
    '';
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
