local M = {}
local mapper = require 'custom.theme-mapper'

M.apply_theme_from_kitty = function()
  local kitty_theme_path = vim.fn.expand '~/.config/kitty/active-theme.conf'
  local kitty_theme = vim.fn.fnamemodify(kitty_theme_path, ':t')
  local nvim_theme = mapper.kitty_to_nvim[kitty_theme]

  if nvim_theme then
    vim.cmd.colorscheme(nvim_theme)
    vim.notify(' Set Neovim colorscheme to: ' .. nvim_theme, vim.log.levels.INFO)
  else
    vim.notify('⚠️ No matching Neovim theme for: ' .. kitty_theme, vim.log.levels.WARN)
  end
end

return M
