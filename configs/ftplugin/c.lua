vim.bo.tabstop = 8 -- size of a hard tabstop (ts).
vim.bo.shiftwidth = 8 -- size of an indentation (sw).
vim.bo.expandtab = false -- always uses spaces instead of tab characters (et).
vim.bo.softtabstop = 8 -- number of spaces a <Tab> counts for. When 0, feature is o

-- Highlight lines longer than textwidth
vim.api.nvim_set_hl(0, 'OverLength', { bg = 'red' })
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufRead', 'BufNewFile' }, {
  pattern = '*',
  callback = function()
    vim.fn.matchadd('OverLength', '\\%81v.*\\S')
  end,
})
