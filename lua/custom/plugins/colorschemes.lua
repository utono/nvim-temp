-- File: ~/.config/nvim/lua/custom/plugins/colorschemes.lua
-- This file configures additional colorschemes outside of the Kickstart default

return {
  {
    'sainnhe/gruvbox-material',
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_foreground = 'material'
      vim.g.gruvbox_material_background = 'hard'
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_enable_italic = 0
      vim.cmd.colorscheme 'gruvbox-material'
    end,
  },

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        flavour = 'mocha',
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
        },
      }
    end,
  },

  {
    'neanias/everforest-nvim',
    version = false,
    priority = 1000,
    config = function()
      require('everforest').setup {
        background = 'hard',
        transparent_background_level = 0,
      }
    end,
  },

  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function()
      require('kanagawa').setup {
        background = {
          dark = 'wave',
        },
      }
    end,
  },

  {
    'loctvl842/monokai-pro.nvim',
    priority = 1000,
    config = function()
      require('monokai-pro').setup()
    end,
  },

  {
    'rose-pine/neovim',
    name = 'rose-pine',
    priority = 1000,
    config = function()
      require('rose-pine').setup {
        variant = 'main',
      }
    end,
  },

  -- Additional popular themes

  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup {
        style = 'night',
        transparent = false,
      }
    end,
  },

  {
    'shaunsingh/nord.nvim',
    priority = 1000,
    config = function()
      vim.g.nord_contrast = true
      vim.g.nord_borders = true
      vim.cmd.colorscheme 'nord'
    end,
  },

  {
    'EdenEast/nightfox.nvim',
    priority = 1000,
    config = function()
      require('nightfox').setup {
        options = {
          transparent = false,
          styles = {
            comments = 'italic',
            keywords = 'bold',
          },
        },
      }
    end,
  },

  {
    'projekt0n/github-nvim-theme',
    priority = 1000,
    config = function()
      require('github-theme').setup {
        options = {
          styles = {
            floats = 'dark',
            sidebars = 'dark',
          },
        },
      }
      vim.cmd.colorscheme 'github_dark_default'
    end,
  },
}
