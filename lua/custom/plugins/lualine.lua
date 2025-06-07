-- File: lua/custom/plugins/lualine.lua

return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = function()
    -- Initial full-statusline config (Zen Mode off by default)
    local function neo_tree_root()
      if vim.g.neo_tree_root then
        return '󰉋 ' .. vim.fn.fnamemodify(vim.g.neo_tree_root, ':~')
      end
      return ''
    end

    local full_sections = {
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

    return {
      options = {
        theme = 'catppuccin',
        globalstatus = true,
        section_separators = '',
        component_separators = '',
      },
      sections = full_sections,
    }
  end,
}
