{
  config,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = pkgs.lib.mkDefault pkgs.linuxPackages_latest;
    kernelParams = ["mitigations=off"];
    tmp.cleanOnBoot = true;
    loader.systemd-boot.configurationLimit = 5;
    loader.grub.configurationLimit = 5;
  };

  services.journald.extraConfig = ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    noto-fonts
    # noto-fonts-cjk-sans
    noto-fonts-color-emoji
    # fira-code
    # fira-code-symbols
    # font-awesome
    nerd-fonts.lilex
  ];

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Microcode / Firmware Update
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

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
  documentation.man.enable = true;
  documentation.dev.enable = true;
  documentation.doc.enable = false;
  documentation.enable = true;

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
    xdg-utils # for opening default programs when clicking links
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout

    # utils
    usbutils
    lshw
    pciutils
    man-pages
    man-pages-posix
    traceroute
    dig
    libvirt
    virt-manager
    wayland
    waypipe
    bluez
    bluez-alsa
    bluez-tools
    iptables
    nss

    libva-utils

    # work
    nix-tree
    podman
    ccache
    vulkan-headers
    vulkan-loader
    vulkan-tools
    adwaita-icon-theme
    gnomeExtensions.appindicator
    qalculate-gtk
    weechat
    swayidle
    wayland-protocols
    nil
    alejandra
    chromium
    bat
    swaylock
    sublime
    pinta
    tomlq
    yazi
    nurl
    btop
    moreutils # errno
    busybox
  ];

  programs.zsh.enable = true;
  programs.dconf.enable = true;
  services.udev.packages = with pkgs; [gnome-settings-daemon];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  programs.ssh = {
    agentTimeout = null;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  programs.ccache = {
    enable = true;
    cacheDir = "/var/cache/ccache";
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = {};
  systemd.user.services.swayidle.enable = true;

  # Wireshark permissions
  users.groups.wireshark.gid = 500;
  security.wrappers.dumpcap = {
    source = "${pkgs.wireshark}/bin/dumpcap";
    permissions = "u+xs,g+x";
    owner = "root";
    group = "wireshark";
  };

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

  # pipewire needs it
  security.rtkit.enable = true;
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
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config = {common = {default = ["gtk"];};};
  };

  services.upower.enable = true;

  # ZSH autocomplete
  environment.pathsToLink = ["/share/zsh"];

  programs.command-not-found.enable = true;

  programs.niri.enable = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      extra-sandbox-paths = [config.programs.ccache.cacheDir];
      trusted-users = ["alberand" "aalbersh"];
      trusted-public-keys = [
        (builtins.readFile ../secrets/cache-public-key.pem)
      ];
      extra-substituters = ["https://noctalia.cachix.org"];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
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
    channel = "https://nixos.org/channels/nixos-unstable";
  };
}
