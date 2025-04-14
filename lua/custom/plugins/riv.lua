return {
  'gu-fan/riv.vim',
  ft = { 'rst' },
  config = function()
    -- Optional riv.vim-specific settings
    vim.g.riv_enable_syntax_highlighting = 1

    -- Autocmd to unfold all folds when opening .rst files
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'rst',
      callback = function()
        vim.cmd 'normal! zR' -- Unfold all folds
      end,
    })
  end,
}
