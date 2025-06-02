-- ~/.config/nvim/lua/custom/lualine_tokyonight.lua
-- Based on tokyonight.nvim's "night" variant

local colors = {
  bg = '#1a1b26',
  fg = '#c0caf5',
  yellow = '#e0af68',
  cyan = '#7dcfff',
  darkblue = '#7aa2f7',
  green = '#9ece6a',
  orange = '#ff9e64',
  violet = '#bb9af7',
  magenta = '#bb9af7',
  blue = '#7aa2f7',
  red = '#f7768e',
}

return {
  normal = {
    a = { bg = colors.blue, fg = colors.bg, gui = 'bold' },
    b = { bg = colors.darkblue, fg = colors.fg },
    c = { bg = colors.bg, fg = colors.fg },
  },
  insert = {
    a = { bg = colors.green, fg = colors.bg, gui = 'bold' },
  },
  visual = {
    a = { bg = colors.magenta, fg = colors.bg, gui = 'bold' },
  },
  replace = {
    a = { bg = colors.red, fg = colors.bg, gui = 'bold' },
  },
  command = {
    a = { bg = colors.yellow, fg = colors.bg, gui = 'bold' },
  },
  inactive = {
    a = { bg = colors.bg, fg = colors.fg },
    b = { bg = colors.bg, fg = colors.fg },
    c = { bg = colors.bg, fg = colors.fg },
  },
}
