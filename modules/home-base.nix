{ config, pkgs, ... }: {
  imports = [
    ./nvim.nix
    ./zsh.nix
    ./waybar.nix
    ./wofi.nix
    ./mako.nix
    ./sway.nix
  ];

  home.packages = with pkgs; [
    acl
    alacritty
    attr
    autoconf
    automake
    b4
    bc
    bemenu
    binutils
    bison
    # Cannot be used together with clang
    # clang
    # clang-tools
    cmake
    cmst
    cscope
    dbench
    e2fsprogs
    elfutils
    feh
    file
    fio
    firefox
    flameshot
    flex
    font-awesome
    foot
    fsverity-utils
    gcc
    gcc
    getopt
    gettext
    glibc
    gnumake
    gnumake
    ima-evm-utils
    isync
    keyutils
    kitty
    libaio
    libelf
    libtool
    linuxquota
    lsof
    m4
    ncurses
    neomutt
    nmap
    notmuch
    nvme-cli
    openssl
    patchutils_0_4_2
    perl
    pkg-config
    python3
    ripgrep
    ripgrep
    stress-ng
    swaylock
    tdesktop
    util-linux
    vlc
    waybar
    wl-clipboard
    xdg-utils
    xfsprogs
    xfstests
    zathura
    zlib
  ];

  home.file = {
    ".ctags" = { source = ../.ctags; };
    ".gdbinit" = { source = ../.gdbinit; };
    ".gitconfig" = { source = ../.gitconfig; };
    ".gitignore" = { source = ../.gitignore; };
    ".mbsyncrc" = { source = ../.mbsyncrc; };
    ".muttrc" = { source = ../.muttrc; };
    ".shrc.local" = { source = ../.shrc.local; };
    ".vimrc.local" = { source = ../.vimrc.local; };
    ".fdignore" = { source = ../configs/.fdignore; };
    ".config/kitty/kitty.conf" = { source = ../configs/.kitty; };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 86400;
  };

  # So, we can autostart it via sway
  services.flameshot = {
    enable = false;
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";
}
