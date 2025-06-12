-- ~/.config/nvim/lua/custom/colorscheme-selector.lua

local M = {}

local favorites = {
  'tokyonight-night',
  'gruvbox-material',
  'catppuccin-mocha',
  'rose-pine',
  'kanagawa',
}

local statefile = vim.fn.stdpath 'state' .. '/last-colorscheme.txt'

-- Load last used colorscheme if state file exists
function M.load_last()
  if vim.fn.filereadable(statefile) == 1 then
    local scheme = vim.fn.readfile(statefile)[1]
    if scheme then
      vim.cmd.colorscheme(scheme)
    end
  end
end

-- Save selected colorscheme to state file
local function save_scheme(scheme)
  local ok = vim.fn.writefile({ scheme }, statefile)
  if ok ~= 0 then
    vim.notify('✔ Colorscheme saved: ' .. scheme, vim.log.levels.INFO)
  else
    vim.notify('❌ Failed to save colorscheme', vim.log.levels.ERROR)
  end
end

-- Pick colorscheme using Telescope with preview
function M.pick()
  local has_telescope, telescope = pcall(require, 'telescope.builtin')
  if not has_telescope then
    vim.notify('❌ telescope.nvim not found', vim.log.levels.ERROR)
    return
  end

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local previewers = require 'telescope.previewers'

  pickers
    .new({}, {
      prompt_title = '🎨 Neovim Colorscheme',
      finder = finders.new_table {
        results = favorites,
      },
      sorter = conf.generic_sorter {},
      previewer = previewers.new_termopen_previewer {
        get_command = function(entry)
          return { 'nvim', '--clean', '--headless', '-c', 'colorscheme ' .. entry.value, '-c', 'q' }
        end,
      },
      attach_mappings = function(_, map)
        local actions = require 'telescope.actions'
        local action_state = require 'telescope.actions.state'
        map('i', '<CR>', function()
          actions.close()
          local selection = action_state.get_selected_entry()
          vim.cmd.colorscheme(selection.value)
          save_scheme(selection.value)
        end)
        map('n', '<CR>', function()
          actions.close()
          local selection = action_state.get_selected_entry()
          vim.cmd.colorscheme(selection.value)
          save_scheme(selection.value)
        end)
        return true
      end,
    })
    :find()
end

return M
