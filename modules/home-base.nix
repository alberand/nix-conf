{pkgs, ...}: {
  imports = [
    ./neovim.nix
    ./zsh.nix
    ./waybar.nix
    ./wofi.nix
    ./mako.nix
    ./sway.nix
    ./git.nix
    ./tmux.nix
    ./kanshi.nix
  ];

  home.packages = with pkgs; [
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
    waybar
    wl-clipboard
    xdg-utils
    zathura
    zlib
    qpwgraph
    jujutsu
    watchman # needed by jujutsu
    stgit
    tree
    zoxide
    devenv
    mergiraf

    (writeShellScriptBin "calc"
      "exec -a $0 ${qalculate-gtk}/bin/qalculate-gtk $@")
    (writeShellScriptBin "tmux-sessionizer"
      (builtins.readFile ../configs/tmux-sessionizer))
    (writeShellScriptBin "todo" (builtins.readFile ../configs/todo.sh))
    (writeShellScriptBin "build-test"
      (builtins.readFile ../configs/build-test.sh))
  ];

  home.file = {
    ".ctags" = {source = ../configs/ctags;};
    ".gdbinit" = {source = ../configs/gdbinit;};
    ".vimrc.local" = {source = ../configs/vimrc.local;};
    ".fdignore" = {source = ../configs/fdignore;};
    ".config/kitty/kitty.conf" = {source = ../configs/kitty;};
    ".tmux.conf" = {source = ../configs/tmux.conf;};
    ".config/jj/config.toml" = {source = ../../configs/jj.toml;};
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    # 400 days
    defaultCacheTtl = 34560000;
    maxCacheTtl = 34560000;
  };

  # So, we can autostart it via sway
  services.flameshot = {enable = false;};

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  services.easyeffects.enable = true;

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
