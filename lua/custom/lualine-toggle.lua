-- File: ~/.config/nvim/lua/custom/lualine-toggle.lua

local M = {}
local zen_mode = false

function M.toggle()
  zen_mode = not zen_mode
  require('lualine').setup {
    options = {
      theme = 'auto',
      globalstatus = not zen_mode,
      section_separators = '',
      component_separators = '',
    },
    sections = zen_mode and {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    } or {
      lualine_a = { 'mode' },
      lualine_b = { 'branch' },
      lualine_c = {
        { 'filename', path = 3 },
        {
          function()
            if vim.g.neo_tree_root then
              return '󰉋 ' .. vim.fn.fnamemodify(vim.g.neo_tree_root, ':~')
            end
            return ''
          end,
          cond = function()
            return vim.g.neo_tree_root ~= nil
          end,
        },
      },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
  }

  if zen_mode then
    vim.opt.laststatus = 0
  else
    vim.opt.laststatus = 3
  end
end

return M
