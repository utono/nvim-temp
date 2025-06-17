-- ~/.config/nvim/lua/custom/plugins/mpv-control.lua

return {
  {
    name = 'mpv-control',
    dir = vim.fn.stdpath 'config' .. '/lua/custom/mpv-control',
    lazy = true,
    config = function()
      vim.api.nvim_create_user_command('MPVSocket', function()
        require('mpv-control').info()
      end, { desc = 'Show active MPV socket' })
    end,
  },
}
