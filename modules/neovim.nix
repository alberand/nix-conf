{pkgs, ...}: let
  rust-vim = pkgs.vimUtils.buildVimPlugin {
    name = "rust.vim";
    src = pkgs.fetchgit {
      url = "https://github.com/rust-lang/rust.vim.git";
      rev = "889b9a7515db477f4cb6808bef1769e53493c578";
      sha256 = "70kp644jOtJ4wguty/SUFX+YEsoxW12LGg3vZh7BdPY=";
    };
  };
  nn = pkgs.vimUtils.buildVimPlugin {
    name = "99";
    src = pkgs.fetchFromGitHub {
      owner = "ThePrimeagen";
      repo = "99";
      rev = "6a64e0b2f4c7f1e3911db1f8318e5d7c68cb8dff";
      hash = "sha256-OOj2bnhxn3Ou7VQOmi3RVPcVs+CqolnJzEgfkXk2p5Q=";
    };
  };
in {
  xdg.configFile."nvim/init.lua".source = ../configs/neovim/init.lua;
  xdg.configFile."nvim/ftplugin".source = ../configs/ftplugin;
  xdg.configFile."nvim/syntax".source = ../configs/neovim/syntax;
  xdg.configFile."nvim/colors".source = ../configs/neovim/colors;

  home.packages = with pkgs; [
    vscode-langservers-extracted
    deadnix
    ruff
  ];

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter
      nvim-treesitter-context
      nvim-treesitter.withAllGrammars
      nvim-fzf
      nvim-lspconfig
      nvim-cmp
      fzf-vim
      telescope-nvim
      vim-nix
      lualine-nvim
      vim-numbertoggle
      vim-plug
      telescope-file-browser-nvim
      harpoon
      rust-vim
      none-ls-nvim
      luasnip
      cmp-nvim-lsp
      nvim-lspconfig
      cmp-buffer
      cmp-path
      cmp_luasnip
      cmp-nvim-lua
      friendly-snippets
      nvim-web-devicons
      trouble-nvim
      # Themes
      zephyr-nvim
      tokyonight-nvim
      # Indent line highlights
      indent-blankline-nvim
      # Git
      gitsigns-nvim
      vim-fugitive
      vim-svelte
      nn
    ];
    extraConfig = ''
      set noexpandtab
    '';
  };
}
