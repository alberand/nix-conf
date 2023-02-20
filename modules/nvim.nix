{ pkgs, ... }:

let 
	nvim-cscope = pkgs.vimUtils.buildVimPluginFrom2Nix {
		name = "nvim-cscope";
		src = pkgs.fetchFromGitHub {
			owner = "alberand";
			repo = "cscope.vim";
			rev = "100e1f1b7b735fdea8654aa27a0b7d02b5acf7d8";
			hash = "sha256-I0fs1+qJnkxP3qib2xFRd0pN0GoYMyIAnKommAbp5Kc=";
		};
	};
in
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
			nvim-cscope

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
	};
}
