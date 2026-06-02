{pkgs, ...}: {
  imports = [
    ./neovim.nix
    ./zsh.nix
    ./wofi.nix
    ./git.nix
    ./tmux.nix
    ./delta.nix
  ];

  home.packages = with pkgs; [
    kitty
    firefox
    zsh
    gdb
    tmux
    mc
    fzf
    fd
    xdg-utils # for opening default programs when clicking links
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    unzip
    man-pages
    man-pages-posix
    libvirt
    qalculate-gtk
    virt-manager
    alejandra
    chromium
    bat
    pinta
    btop
    moreutils # errno
    sublime
    cmst
    feh
    file
    firefox
    flameshot
    foot
    nmap
    openssl
    python3
    jq
    ripgrep
    util-linux
    wl-clipboard
    xdg-utils
    zathura
    zlib
    jujutsu
    watchman # needed by jujutsu
    stgit
    tree
    zoxide
    devenv
    mergiraf
    colordiff

    (writeShellScriptBin "calc"
      "exec -a $0 ${qalculate-gtk}/bin/qalculate-gtk $@")
    (writeShellScriptBin "tmux-sessionizer"
      (builtins.readFile ../configs/tmux-sessionizer))
    (writeShellScriptBin "todo" (builtins.readFile ../configs/todo.sh))
    (writeShellScriptBin "build-test"
      (builtins.readFile ../configs/build-test.sh))
    (writeShellScriptBin "compare-branches"
      (builtins.readFile ../configs/compare-branches.sh))
  ];

  home.file = {
    ".ctags" = {source = ../configs/ctags;};
    ".gdbinit" = {source = ../configs/gdbinit;};
    ".vimrc.local" = {source = ../configs/vimrc.local;};
    ".fdignore" = {source = ../configs/fdignore;};
    ".config/kitty/kitty.conf" = {source = ../configs/kitty;};
    ".tmux.conf" = {source = ../configs/tmux.conf;};
    ".config/jj/config.toml" = {source = ../configs/jj.toml;};
    ".emailaliases" = {source = ../configs/emailaliases;};
  };
  xdg.configFile."niri/config.kdl".source = ../configs/niri.kdl;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    # 400 days
    defaultCacheTtl = 34560000;
    maxCacheTtl = 34560000;
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  xdg.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
