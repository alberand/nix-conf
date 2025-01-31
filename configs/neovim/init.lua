-- Theme
vim.cmd[[colorscheme tokyonight]]

-- <leader> key
vim.g.mapleader = ","
vim.g.nobomb = true

-- Fat cursor
vim.opt.guicursor = ""
vim.opt.cursorline = true

-- 80 chars column limit
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
vim.opt.syntax = "on"
vim.opt.cc = "+1"

-- Folding
vim.opt.foldmethod = "syntax"
vim.opt.foldlevel = 20

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Case-insensitive searching UNLESS \C or one or more capital letters in the
-- search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = false
vim.opt.listchars = { trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

vim.opt.autoindent = true

-- TODO this should move to c filetype
vim.opt.tabstop = 8
-- Doesn't work somehow
vim.opt.expandtab = false
--vim.cmd[[ set noexpandtab ]]
vim.opt.shiftwidth = 8
vim.opt.softtabstop = 0

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

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

-- Splits appear in right place
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Wrapping doesn't always work good with really long lines (break theme)
vim.opt.wrap = true

-- Undo history
vim.opt.undofile = true

-- Linux dev related
-- Whitespace damage
vim.cmd[[ highlight RedundantSpaces ctermbg=red guibg=red ]]
vim.cmd[[ match RedundantSpaces /\s\+$\| \+\ze\t/ ]]

-- Use .vimrc if it is appear in current folder. !!!DANGER!!!
vim.opt.exrc = true
vim.opt.secure = true

if (os.execute('test -f ~/.vimrc.local') == 0)
then
     vim.cmd('source ~/.vimrc.local')
end

-- Disable LSP log as it can grew pretty big
-- When needed enable with
-- vim.lsp.set_log_level("debug")
vim.lsp.set_log_level("off")

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

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

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Review tag for Kernel work
vim.keymap.set('i', '<C-s>', 'Reviewed-by: Andrey Albershteyn <aalbersh@kernel.org>')

-- Plugins

-- Status line
require('lualine').setup()

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
  -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
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

-- Telescope configuration
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<C-i>', builtin.live_grep, {})
vim.keymap.set('n', '<leader>i', builtin.lsp_references, {})
vim.keymap.set('n', '<leader>f', '<cmd>lua require(\'telescope.builtin\').grep_string({search = vim.fn.expand("<cword>")})<cr>', {})
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })

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
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "off"
        }
      }
    }
}
require('lspconfig')['ts_ls'].setup{
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

require('lspconfig')['nil_ls'].setup({ })

require("harpoon").setup({ })

vim.keymap.set('n', "<leader>a", function() require("harpoon.mark").add_file() end, silent)
vim.keymap.set('n', "<C-e>", function() require("harpoon.ui").toggle_quick_menu() end, silent)
vim.keymap.set('n', "<leader>tc", function() require("harpoon.cmd-ui").toggle_quick_menu() end, silent)

vim.keymap.set('n', "<leader>t", function() require("harpoon.ui").nav_file(1) end, silent)
vim.keymap.set('n', "<leader>r", function() require("harpoon.ui").nav_file(2) end, silent)
vim.keymap.set('n', "<leader>e", function() require("harpoon.ui").nav_file(3) end, silent)
vim.keymap.set('n', "<leader>w", function() require("harpoon.ui").nav_file(4) end, silent)

local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.deadnix,
        null_ls.builtins.formatting.alejandra,
    },
})
vim.keymap.set('n', '<C-a>', ':lua vim.lsp.buf.format()<CR>')

-- Trouble
vim.keymap.set("n", "<leader>x", function() require("trouble").toggle() end)
vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end)
vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end)
vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end)
vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("loclist") end)
vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end)

require('treesitter-context').setup{
    -- Function with hugh header taking too much space
    max_lines = 2,
}

require("ibl").setup {
	scope = {
		priority = 1000,
		highlight = {"Function", "Label"},
	},
}

-- Integration with git (these green/blue/red lines on the left)
require('gitsigns').setup{
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end)

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk)
    map('n', '<leader>hr', gitsigns.reset_hunk)
    map('v', '<leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('n', '<leader>hS', gitsigns.stage_buffer)
    map('n', '<leader>hu', gitsigns.undo_stage_hunk)
    map('n', '<leader>hR', gitsigns.reset_buffer)
    map('n', '<leader>hp', gitsigns.preview_hunk)
    map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end)
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
    map('n', '<leader>hd', gitsigns.diffthis)
    map('n', '<leader>hD', function() gitsigns.diffthis('~') end)
    map('n', '<leader>td', gitsigns.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}
