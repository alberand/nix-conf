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

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.zsh
    pkgs.firefox
    pkgs.networkmanager
    pkgs.libcec
    pkgs.v4l-utils
    pkgs.util-linux
    pkgs.busybox
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
      allowedTCPPorts = [ 8384 ];
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

  age.secrets.tailscale.file = ../../secrets/quesada-tskey.age;
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.age.secrets.tailscale.path;
    # TODO Not sure that I need it
    extraUpFlags = ["--advertise-tags=tag:lonely"];
  };

  systemd.services.tailscaled-autoconnect.after = ["network-online.service"];

  users.extraUsers.kodi.isNormalUser = true;
  services.cage.user = "kodi";
  services.cage.program = let
    kodi = pkgs.kodi-wayland.withPackages (kodiPkgs:
      with kodiPkgs; [
        jellyfin
        youtube
        keymap
      ]);
  in "${kodi}/bin/kodi-standalone";
  services.cage.enable = true;
  services.cage.extraArguments = ["-s" "-d"];

  environment.persistence."/persistent" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
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
    };
    users.kodi = {
      directories = [
        {
          directory = ".kodi";
          mode = "0755";
        }
        {
          directory = "photos";
          mode = "0755";
        }
        {
          directory = ".config/syncthing";
          mode = "0755";
        }
      ];
    };
  };

  services.syncthing = {
    enable = true;
    dataDir = "/home/kodi/photos";
    configDir = "/home/kodi/.config/syncthing";
    # overrides any devices added or deleted through the WebUI
    overrideDevices = true;
    # overrides any folders added or deleted through the WebUI
    overrideFolders = true;
    # Open firewall ports
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    user = "kodi";
    group = "users";
    settings = {
      devices = {
        "nixxy" = {
          id = "QZWNQM5-IH7BAU5-INVUVQO-Q4XDK45-SJUFUAJ-XFQMLBJ-2RYAYHS-NEACKA7";
        };
      };

      folders = {
        "quesada-photos" = {
          path = "/home/kodi/photos";
          devices = ["nixxy"];
        };
      };
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
