return {
  'jvgrootveld/telescope-zoxide',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    require('telescope').setup {
      extensions = {
        zoxide = {
          prompt_title = '[ Zoxide ]',
          list_command = 'zoxide query -ls',
          mappings = {
            default = {
              action = function(selection)
                vim.cmd('cd ' .. selection.path)
              end,
              after_action = function(selection)
                print('Directory changed to ' .. selection.path)
              end,
            },
          },
        },
      },
    }
    pcall(require('telescope').load_extension, 'zoxide')

    -- Keymap for zoxide using <leader>'
    -- vim.keymap.set('n', '<leader>nn', function()
    -- require('telescope').extensions.zoxide.list()
    -- end, { desc = '[Z]oxide Fuzzy Finder' })
  end,
}
