{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./modules/wireguard.nix
    ./modules/podman-deluge.nix
    ./modules/nginx.nix
    ./modules/grafana.nix
    ./modules/tmux.nix
    ./modules/qemu-guest-network.nix
    ./modules/home-assistant.nix
    ./modules/mysql.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
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
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Vulkan API/OpenCL API/Modern AMD Graphics Core Next (GCN) GPUs
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
      amdvlk
    ];
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME	= "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";

    PATH = [
      "\${XDG_BIN_HOME}"
    ];
  };

  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  };

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    fira-code
    fira-code-symbols
    inconsolata
    dina-font
    proggyfonts
    nerdfonts
    font-awesome
  ];

  networking = {
    hostName = "nixxy";
    # Pick only one of the below networking options.
    networkmanager.enable = true;
    networkmanager.dns = "default";
    defaultGateway = "192.168.0.1";
    # nameservers = [ "8.8.8.8" "1.1.1.1" ];
    interfaces.enp34s0.useDHCP = true;
    # VPN configuration
    # Configure the NAT/Firewall
    firewall.enable = true;
    # TODO not sure what it is but Tailscale wants it
    firewall.checkReversePath = "loose";
    firewall = {
      allowedTCPPorts = [ 53 22 8384 22000 ];
      allowedUDPPorts = [ 53 51820 22000 21027];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LANGUAGE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
    LC_TYPE = "en_US.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.variables.EDITOR = "nvim";
  documentation.dev.enable = true;

  services.udev.extraRules = ''
    # ash drive
    SUBSYSTEMS=="usb", ATTR{idVendor}=="8564", ATTR{idProduct}=="1000", MODE="0660", OWNER="alberand"
  '';

  # Media group to access media storage
  users.groups.media = {
    name = "media";
    gid = 8096;
    members = [ "alberand" "jellyfin" "deluge" "photoprism" ];
  };

  users.users.deluge = {
    isNormalUser = true;
    description = "Deluge";
    extraGroups = [ "media" ];
    uid = 1002;
  };

  users.users.jellyfin = {
    description = "JellyFin";
    extraGroups = [ "media" "render" "video" ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alberand = {
    isNormalUser = true;
    description = "Andrey Albershteyn";
    uid = 1000;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "sudo"
      "libvirt"
      "networkmanager"
      "wireshark"
      "disk"
    ];
  };

  programs.zsh.enable = true;

  system.activationScripts = {
    text = ''
      mkdir -p /export
    '';
  };

  # https://github.com/NixOS/nixpkgs/issues/24570
  fileSystems."/export/alberand" = {
    device = "/home/alberand/Share/local";
    options = [ "bind" ];
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
    zsh
    gdb
    tmux
    mc
    fzf
    fd

    # utils
    usbutils
    lshw
    pciutils
    ntfs3g
    wine
    wine-wayland
    man-pages
    man-pages-posix
    pinentry
    libva-utils

    # work
    qemu_full
    qemu-utils
    trace-cmd
    # xfstests

    # video
    mesa
    mesa-demos
    vulkan-tools
    vulkan-headers
    vulkan-loader
    radeontop
    libgdiplus
    jellyfin-ffmpeg
    rocm-opencl-runtime
    libva
  ];

  security.polkit.enable = true;
  systemd.user.services.waybar.enable = true;
  systemd.user.services.swayidle.enable = true;

  # Dynamic display configuration
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi'';
      RestartSec = 5;
      Restart = "always";
    };
  };

  # Enable sound.
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Wireshark permissions
  users.groups.wireshark.gid = 500;
  security.wrappers.dumpcap = {
    source = "${pkgs.wireshark}/bin/dumpcap";
    permissions = "u+xs,g+x";
    owner = "root";
    group = "wireshark";
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

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
    };
  };

  programs.ssh = {
    startAgent = false;
    agentTimeout = "24h";
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "tty";
    enableSSHSupport = true;
  };

  security.rtkit.enable = true;
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  virtualisation = {
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a
      # drop-in replacement
      dockerCompat = true;
    };
  };

  programs.kdeconnect.enable = true;

  services.syncthing = {
    enable = true;
    dataDir = "/home/alberand/Share";
    configDir = "/home/alberand/.config/syncthing";
    # overrides any devices added or deleted through the WebUI
    overrideDevices = true;
    # overrides any folders added or deleted through the WebUI
    overrideFolders = false;
    user = "alberand";
    group = "users";
    devices = {
      "lonmoun" = {
        id = "BHZVVJE-BKYAHGR-6ET6T2T-O7SRFSC-AKQEOP3-KYR4JME-ARSWMAB-HQSRBQL";
      };
      "nothing-phone" = {
        id = "74LMGV3-VGBB6J7-CT7LRHY-CANX5WF-UOVYYXG-762UH5M-6HFZKLB-AXNP2QW";
      };
    };

    folders = {
      "Documents" = {
        path = "/home/alberand/Share/Documents";
        devices = [ "lonmoun" "nothing-phone" ];
      };
    };
  };

  services.photoprism = {
    enable = true;
    port = 8113;
    originalsPath = "/media/photos";
    settings = {
      PHOTOPRISM_ADMIN_USER = "alberand";
      PHOTOPRISM_ADMIN_PASSWORD = "123456";
    };

  };

  programs.ccache.enable = true;
  programs.ccache.cacheDir = "/var/cache/ccache";
  programs.ccache.packageNames = [ "kernel-cache" ];

  services.nfs.server.enable = true;
  # TODO probably need to make it more safe regarding the permission
  services.nfs.server.exports = ''
    /export          192.168.0.101(rw,fsid=0,no_subtree_check)
    /export/alberand 192.168.0.101(rw,nohide,insecure,no_subtree_check,all_squash,anonuid=1000,anongid=100)
  '';

  services.journald.extraConfig = ''
    SystemMaxUse=20M
  '';

  nix = {
    settings = {
      # needed by direnv so shell don't get garbage collected
      keep-outputs = true;
      keep-derivations = true;
      auto-optimise-store = true;
      extra-sandbox-paths = [
        config.programs.ccache.cacheDir
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixVersions.unstable;
    extraOptions = ''
                  experimental-features = nix-command flakes
                  keep-outputs = true
                  keep-derivations = true
    '';
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    channel = https://nixos.org/channels/nixos-unstable;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
