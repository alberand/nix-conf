vim.opt.spell = false
vim.cmd[[ highlight RedundantSpaces ctermbg=red guibg=red ]]
vim.cmd[[ match RedundantSpaces /\s\+$\| \+\ze\t/ ]]
