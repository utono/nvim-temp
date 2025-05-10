-- lua/custom/autocmds.lua

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.txt',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})
