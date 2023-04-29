vim.g.mapleader = ","
vim.cmd[[ colorscheme zephyr ]]
vim.g.nobomb = true
-- Fat cursor
vim.opt.guicursor = ""
vim.opt.cursorline = true
vim.opt.tw = 80
vim.opt.textwidth = 80
-- Error column always on
vim.opt.signcolumn = "yes"
-- Line numbering
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.smartindent = true
-- Syntax coloring lines that are too long just slows down the world
vim.opt.synmaxcol = 128
vim.opt.syntax = "enable"
vim.opt.cc = "+1"
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 20
vim.opt.pastetoggle = "<F5>"

vim.opt.tabstop = 8
vim.opt.autoindent = true
-- Doesn't work somehow
vim.opt.expandtab = false
--vim.cmd[[ set noexpandtab ]]
vim.opt.shiftwidth = 8
vim.opt.softtabstop = 0

vim.opt.listchars = {
	--eol = '↵',
	space = ' ',
	tab = '> '
}
vim.opt.list = true

-- Search highlight
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Spell check
vim.opt.spell = true
vim.opt.spelllang = "en_us"
-- <leader>s to enable spell
vim.keymap.set('n', '<silent> <leader>s', ':set spell!<CR>')
-- Auto correct last word in insert mode by CTRL+e
vim.keymap.set('i', '<C-e>', '<Esc>[s1z=`]a')

-- File encondings
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.termencoding = "utf-8"

-- Use .vimrc if it is appear in current folder. !!!DANGER!!!
vim.opt.exrc = true
vim.opt.secure = true

-- Splits appear in right place
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Undo history
vim.opt.undofile = true
-- vim.opt.undodir = '~/.nvim/undo//'
-- vim.opt.backupdir = '~/.nvim/backup//'
-- vim.opt.directory = '~/.nvim/swp//'

-- Linux dev related
-- Whitespace damage
vim.cmd[[ highlight RedundantSpaces ctermbg=red guibg=red ]]
vim.cmd[[ match RedundantSpaces /\s\+$\| \+\ze\t/ ]]

if (os.execute('test -f ~/.vimrc.local') == 0)
then
     vim.cmd('source ~/.vimrc.local')
end

-- Mappings.
-- Split navigation witouh CTRL+W
vim.keymap.set('n', '<C-j>', '<C-W>j')
vim.keymap.set('n', '<C-k>', '<C-W>k')
vim.keymap.set('n', '<C-h>', '<C-W>h')
vim.keymap.set('n', '<C-l>', '<C-W>l')
-- Navigation in insert mode
vim.keymap.set('i', '<C-j>', '<Down>')
vim.keymap.set('i', '<C-k>', '<Up>')
vim.keymap.set('i', '<C-h>', '<Left>')
vim.keymap.set('i', '<C-l>', '<Right>')

-- Move blocks with JK
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Smarter J line add
vim.keymap.set("n", "J", "mzJ`z")
-- Half page jumps are in the middle of the screen
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- Search terms are in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Copy to clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Space to goggle folds.
vim.keymap.set('n', '<Space>', 'za')
vim.keymap.set('v', '<Space>', 'za')

-- Set paste to mode to F5
vim.keymap.set('n', '<F5>', ':set invpaste paste?<Enter>')
vim.keymap.set('i', '<F5>', '<C-O><F5>')

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- fzf configuration
-- vim.keymap.set('n', '<C-p>', ':FZF<CR>')
-- vim.keymap.set('n', '<C-i>', ':Tags<CR>')
--
-- Telescope configuration
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<C-i>', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

local ts_select_dir_for_grep = function(prompt_bufnr)
  local action_state = require("telescope.actions.state")
  local fb = require("telescope").extensions.file_browser
  local live_grep = require("telescope.builtin").live_grep
  local current_line = action_state.get_current_line()

  fb.file_browser({
    files = false,
    depth = false,
    attach_mappings = function(prompt_bufnr)
      require("telescope.actions").select_default:replace(function()
        local entry_path = action_state.get_selected_entry().Path
        local dir = entry_path:is_dir() and entry_path or entry_path:parent()
        local relative = dir:make_relative(vim.fn.getcwd())
        local absolute = dir:absolute()

        live_grep({
          results_title = relative .. "/",
          cwd = absolute,
          default_text = current_line,
        })
      end)

      return true
    end,
  })
end

local actions = require("telescope.actions")
require("telescope").setup({
    defaults = {
        mappings = {
            i = {
		-- Exit with single <esc>
                ["<esc>"] = actions.close,
            },
        },
    },
    pickers = {
     live_grep = {
      mappings = {
        i = {
          ["<C-f>"] = ts_select_dir_for_grep,
        },
        n = {
          ["<C-f>"] = ts_select_dir_for_grep,
        },
      },
    },
  }
})

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}
require('lspconfig')['pyright'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
require('lspconfig')['tsserver'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
require('lspconfig')['rust_analyzer'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
    -- Server-specific settings...
    settings = {
      ["rust-analyzer"] = {}
    }
}
require('lspconfig')['clangd'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
