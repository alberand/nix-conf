{ config, pkgs, ... }: {
  imports = [
    ./nvim.nix
    ./zsh.nix
    ./waybar.nix
    ./wofi.nix
    ./mako.nix
    ./sway.nix
    ./git.nix
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
    jq
    ripgrep
    ripgrep
    stress-ng
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
    qpwgraph
    droidcam
    (writeShellScriptBin "calc" "exec -a $0 ${qalculate-gtk}/bin/qalculate-gtk $@")
    (writeShellScriptBin "tmux-sessionizer" (builtins.readFile ../configs/tmux-sessionizer))
    (writeShellScriptBin "todo" (builtins.readFile ../configs/todo.sh))
  ];

  home.file = {
    ".ctags" = { source = ../.ctags; };
    ".gdbinit" = { source = ../.gdbinit; };
    ".vimrc.local" = { source = ../.vimrc.local; };
    ".fdignore" = { source = ../configs/.fdignore; };
    ".config/kitty/kitty.conf" = { source = ../configs/.kitty; };
    ".tmux.conf" = { source = ../configs/tmux.conf; };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    # 400 days
    defaultCacheTtl = 34560000;
    maxCacheTtl = 34560000;
  };

  # So, we can autostart it via sway
  services.flameshot = {
    enable = false;
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  services.easyeffects.enable = true;

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
