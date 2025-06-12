-- gruvbox-material.lua
--
-- Load and configure the Gruvbox Material theme for Neovim.
-- This script follows the kickstart-modular.nvim format.
--
-- Source: https://github.com/sainnhe/gruvbox-material
--
return {
  {
    -- Gruvbox Material theme from Sainnhe
    'sainnhe/gruvbox-material',
    priority = 1000, -- Ensure it loads before other start plugins
    config = function()
      -- Theme variant: 'soft', 'medium', or 'hard'
      vim.g.gruvbox_material_background = 'hard'

      -- Optional settings to make it match Kitty more closely
      vim.g.gruvbox_material_foreground = 'material' -- or 'mix', 'original'
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_enable_italic = 0

      -- Load the colorscheme
      vim.cmd.colorscheme 'gruvbox-material'

      -- Customize highlights if needed
      vim.cmd.hi 'Comment gui=none'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
