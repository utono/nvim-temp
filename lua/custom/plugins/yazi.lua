---@type LazySpec
return {
  'mikavilpas/yazi.nvim',
  event = 'VeryLazy',
  keys = {
    -- Open Yazi at the current file
    {
      -- '<leader>-',
      ',',
      mode = { 'n', 'v' },
      '<cmd>Yazi<cr>',
      desc = 'Open yazi at the current file',
    },
    -- Open Yazi in Neovim's working directory
    {
      '<leader>cw',
      '<cmd>Yazi cwd<cr>',
      desc = "Open the file manager in nvim's working directory",
    },
    -- Resume the last Yazi session
    {
      '<c-up>',
      '<cmd>Yazi toggle<cr>',
      desc = 'Resume the last yazi session',
    },
  },
  ---@type YaziConfig
  opts = {
    open_for_directories = false,
    keymaps = {
      show_help = '<f1>',
    },
  },
}
