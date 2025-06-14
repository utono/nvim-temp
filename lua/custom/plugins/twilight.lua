-- File: lua/custom/plugins/twilight.lua
-- Twilight dims inactive portions of the code, enhancing focus during editing

return {
  'folke/twilight.nvim',
  ft = { 'lua', 'python' },
  opts = {
    dimming = {
      alpha = 0.25, -- amount of dimming
      color = { 'Normal', '#ffffff' },
      inactive = true,
    },
    context = 10,
    treesitter = true,
    expand = {
      'function',
      'method',
      'table',
      'if_statement',
    },
    exclude = {},
  },
  config = function(_, opts)
    require('twilight').setup(opts)
    vim.schedule(function()
      local ft = vim.bo.filetype
      if ft == 'lua' or ft == 'python' then
        vim.cmd.TwilightEnable()
      end
    end)
  end,
}
