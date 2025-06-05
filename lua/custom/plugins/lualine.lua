local zen_mode = false

return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = function()
    local function neo_tree_root()
      if vim.g.neo_tree_root then
        return '󰉋 ' .. vim.fn.fnamemodify(vim.g.neo_tree_root, ':~')
      end
      return ''
    end

    local function minimal_sections()
      return {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
        -- lualine_z = {
        --   {
        --     'filename',
        --     path = 0,
        --     color = { fg = '#4b5263', bg = 'none' }, -- darker gray, transparent bg
        --     symbols = {
        --       modified = ' [+]',
        --       readonly = ' [-]',
        --       unnamed = '[No Name]',
        --     },
        --   },
        -- },
      }
    end

    local function full_sections()
      return {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
        lualine_c = {
          { 'filename', path = 3 },
          {
            neo_tree_root,
            cond = function()
              return vim.g.neo_tree_root ~= nil
            end,
          },
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      }
    end

    local function toggle_zen_statusline()
      zen_mode = not zen_mode
      require('lualine').setup {
        options = {
          theme = 'catppuccin',
          globalstatus = true,
          section_separators = '',
          component_separators = '',
        },
        sections = zen_mode and minimal_sections() or full_sections(),
      }
    end

    vim.api.nvim_create_user_command('ToggleStatuslineZen', toggle_zen_statusline, {})

    return {
      options = {
        theme = 'catppuccin',
        globalstatus = true,
        section_separators = '',
        component_separators = '',
      },
      sections = full_sections(),
    }
  end,
}
