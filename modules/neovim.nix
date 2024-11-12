{ pkgs, ... }: let
  rust-vim = pkgs.vimUtils.buildVimPlugin {
      name = "rust.vim";
      src = pkgs.fetchgit {
        url = "https://github.com/rust-lang/rust.vim.git";
        rev = "889b9a7515db477f4cb6808bef1769e53493c578";
        sha256 = "70kp644jOtJ4wguty/SUFX+YEsoxW12LGg3vZh7BdPY=";
      };
  };
in {
  xdg.configFile."nvim/init.lua".source = ../configs/neovim/init.lua;
  xdg.configFile."nvim/ftplugin".source = ../configs/ftplugin;

  home.packages = with pkgs; [
    vscode-langservers-extracted
    lua-language-server
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
      vim-airline
      vim-airline-themes
      vim-numbertoggle
      vim-plug
      zephyr-nvim
      telescope-file-browser-nvim
      harpoon
      rust-vim
      vim-fugitive
      null-ls-nvim
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
      # Indent line highlights
      indent-blankline-nvim
    ];
    extraConfig = ''
    set noexpandtab
    '';
  };
}
