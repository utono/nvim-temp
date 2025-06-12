-- ~/.config/nvim/lua/custom/plugins/colorscheme-selector.lua
-- Telescope-powered Neovim colorscheme selector with favorites and persistence

local M = {}

-- Customize this list with your favorite colorschemes
local favorites = {
  'tokyonight-night',
  'gruvbox-material',
  'everforest',
  'catppuccin-mocha',
  'rose-pine',
  'kanagawa',
  'monokai-pro',
}

local state_file = vim.fn.stdpath 'cache' .. '/last-colorscheme.txt'

-- Apply a colorscheme and persist it
local function apply_colorscheme(name)
  vim.cmd.colorscheme(name)
  local ok = pcall(vim.fn.writefile, { name }, state_file)
  if not ok then
    vim.notify('Failed to save last colorscheme', vim.log.levels.WARN)
  end
end

-- Load last used colorscheme if present
function M.load_last()
  local f = io.open(state_file, 'r')
  if f then
    local scheme = f:read '*l'
    f:close()
    if scheme and vim.fn.hlexists 'Normal' == 1 then
      pcall(vim.cmd.colorscheme, scheme)
    end
  end
end

-- Launch Telescope picker with favorites
function M.pick()
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  pickers
    .new({}, {
      prompt_title = '🎨 Neovim Colorscheme',
      finder = finders.new_table {
        results = favorites,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(_, map)
        actions.select_default:replace(function()
          actions.close(_)
          local selection = action_state.get_selected_entry()
          if selection then
            apply_colorscheme(selection[1])
            vim.notify('Applied colorscheme: ' .. selection[1], vim.log.levels.INFO)
          end
        end)
        return true
      end,
    })
    :find()
end

return M
