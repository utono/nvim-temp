-- ~/.config/nvim/lua/custom/plugins/mpv_chapter.lua

return {
  dir = vim.fn.stdpath 'config' .. '/lua/custom/plugins/mpv_chapter',
  name = 'mpv_chapter',
  lazy = false,
  config = function()
    require('custom.plugins.mpv_chapter').setup()
  end,
}
