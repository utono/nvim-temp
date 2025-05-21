vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.txt',
  callback = function()
    -- Disable line numbers and set infinite scrolloff
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.scrolloff = 999
    -- Set solid black background and white foreground for Normal, NormalNC, and SignColumn
    vim.cmd 'highlight Normal guibg=#000000 guifg=#ffffff'
    vim.cmd 'highlight NormalNC guibg=#000000 guifg=#ffffff'
    vim.cmd 'highlight SignColumn guibg=#000000 guifg=#ffffff'
    vim.cmd 'highlight VertSplit guibg=#000000'
  end,
})
