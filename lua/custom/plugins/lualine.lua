return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      theme = 'auto', -- You can use 'auto' if you're setting highlights manually
      section_separators = { left = '', right = '' },
      component_separators = { left = '', right = '' },
      globalstatus = true,
      disabled_filetypes = { statusline = { 'dashboard', 'alpha' } },
    },

    sections = {
      lualine_a = {
        { 'mode', separator = { left = '' }, right_padding = 1 },
      },
      lualine_b = {
        { 'branch', icon = '' },
        'diff',
        'diagnostics',
      },
      lualine_c = {
        {
          'filename',
          path = 1, -- 0: just filename, 1: relative, 2: absolute
          symbols = {
            modified = ' ●',
            readonly = ' ',
            unnamed = '[No Name]',
          },
        },
      },
      lualine_x = {
        { 'filetype', icon_only = true },
        'encoding',
        'fileformat',
      },
      lualine_y = {
        {
          function()
            return os.date ' %R'
          end,
          color = { fg = '#1d2021', bg = '#458588' }, -- Gruvbox Blue
          separator = '',
        },
      },
      lualine_z = {
        {
          'location',
          separator = { right = '' },
          left_padding = 1,
        },
      },
    },

    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          'filename',
          path = 1,
          symbols = { modified = ' ●', readonly = ' ' },
        },
      },
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {},
    },
  },
}
