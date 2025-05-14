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
    (b4.overrideAttrs (final: prev: {
      version = "git";
      # Latest master as of 12.05.25
      src = pkgs.fetchgit {
        url = "git://git.kernel.org/pub/scm/utils/b4/b4.git";
        rev = "6f78e874e96b0b3bac1767a1743b20af20cb0e2f";
        hash = "sha256-fPtXfycJfLhHmqVIrrnHB9JNee1Q3VuIi+FXbcy8bOE=";
      };
      patches = [
        ../patches/0001-ez-introduce-in-reply-to-for-send.patch
        ../patches/0001-ez-introduce-branch-BRANCH-argument-for-send.patch
      ];
    }))
    cmst
    feh
    file
    firefox
    flameshot
    foot
    isync
    neomutt
    nmap
    notmuch
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
    zeal
    python3
    jujutsu
    stgit
    meld
    tree
    zoxide
    pinentry

    (writeShellScriptBin "calc"
      "exec -a $0 ${qalculate-gtk}/bin/qalculate-gtk $@")
    (writeShellScriptBin "tmux-sessionizer"
      (builtins.readFile ../configs/tmux-sessionizer))
    (writeShellScriptBin "todo" (builtins.readFile ../configs/todo.sh))
  ];

  home.file = {
    ".ctags" = {source = ../configs/ctags;};
    ".gdbinit" = {source = ../configs/gdbinit;};
    ".vimrc.local" = {source = ../configs/vimrc.local;};
    ".fdignore" = {source = ../configs/fdignore;};
    ".config/kitty/kitty.conf" = {source = ../configs/kitty;};
    ".tmux.conf" = {source = ../configs/tmux.conf;};
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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";
}
