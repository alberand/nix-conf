{ pkgs, ... }:

{
	xdg.configFile."nvim/init.lua".source = ../configs/neovim/init.lua;
	programs.neovim = {
		enable = true;
		plugins = with pkgs.vimPlugins; [ 
			nvim-treesitter 
			nvim-fzf
			fzf-vim
			telescope-nvim
			nvim-treesitter-context
			vim-nix
			vim-airline 
			vim-airline-themes
			vim-numbertoggle
			vim-plug 
			zephyr-nvim

			# lsp-zero deps
			nvim-lspconfig
			nvim-cmp
			luasnip
			cmp-nvim-lsp
			nvim-lspconfig
			cmp-buffer
			cmp-path
			cmp_luasnip
			cmp-nvim-lua
			friendly-snippets
		];
		extraConfig = ''
		set noexpandtab
		'';
		  
	};
}
