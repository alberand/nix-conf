{ config, pkgs, ... }: {
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

  services.journald.extraConfig = ''
    SystemMaxUse=20M
  '';

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

    # work
    qemu_full
    qemu-utils
    trace-cmd
  ];

  programs.zsh.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
    };
  };

  programs.ssh = {
    startAgent = true;
    agentTimeout = "24h";
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "tty";
    enableSSHSupport = false;
  };

  security.polkit.enable = true;
  systemd.user.services.waybar.enable = true;
  systemd.user.services.swayidle.enable = true;

  nix = {
    settings = {
      # needed by direnv so shell don't get garbage collected
      keep-outputs = true;
      keep-derivations = true;
      auto-optimise-store = true;
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
    enable = false;
    allowReboot = false;
    channel = https://nixos.org/channels/nixos-unstable;
  };
}
