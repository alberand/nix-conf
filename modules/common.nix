{ config, pkgs, ... }: {
  environment.sessionVariables = rec {
    XDG_CACHE_HOME	= "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    HOSTNAME = "${config.networking.hostName}";

    PATH = [
      "\${XDG_BIN_HOME}"
    ];
  };

  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  };

  services.journald.extraConfig = ''
    SystemMaxUse=20M
  '';

  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    fira-code
    fira-code-symbols
    inconsolata
    dina-font
    proggyfonts
    nerdfonts
    font-awesome
    jetbrains-mono
  ];

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
    man-pages
    man-pages-posix
    pinentry
    libva-utils
    traceroute
    dig
    libvirt
    wayland
    waypipe
    bluez
    bluez-alsa
    bluez-tools
    wireshark
    parted
    iptables
    tldr
    nss

    # work
    qemu_full
    qemu-utils
    trace-cmd
    nix-tree
    podman
    ccache
    vulkan-headers
    vulkan-loader
    vulkan-tools
    gimp
    easyeffects
    adwaita-icon-theme
    gnomeExtensions.appindicator
    rustc
    cargo
    qalculate-gtk
    weechat
    swayidle
    wayland-protocols
    nil
    alejandra
    deadnix
    chromium
    bat
    swaylock
    sublime
    yt-dlp
    pinta
    xournalpp
    nix-prefetch
    nix-prefetch-git
    tomlq
  ];

  programs.zsh.enable = true;
  programs.dconf.enable = true;
  services.udev.packages = with pkgs; [
    gnome-settings-daemon
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
    };
  };

  programs.ssh = {
    startAgent = true;
    agentTimeout = null;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  programs.ccache.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = {};
  systemd.user.services.waybar.enable = true;
  systemd.user.services.swayidle.enable = true;

  # Wireshark permissions
  users.groups.wireshark.gid = 500;
  security.wrappers.dumpcap = {
    source = "${pkgs.wireshark}/bin/dumpcap";
    permissions = "u+xs,g+x";
    owner = "root";
    group = "wireshark";
  };

  nix = {
    settings = {
      # needed by direnv so shell don't get garbage collected
      keep-outputs = true;
      keep-derivations = true;
      auto-optimise-store = true;
      extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixVersions.git;
    extraOptions = ''
                  experimental-features = nix-command flakes
                  keep-outputs = true
                  keep-derivations = true
    '';
  };

  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
    channel = "https://nixos.org/channels/nixos-unstable";
  };
}
