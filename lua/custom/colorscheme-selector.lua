-- File: ~/.config/nvim/lua/custom/colorscheme-selector.lua

local M = {}

local favorites = {
  'tokyonight-night',
  'gruvbox-material',
  'catppuccin-mocha',
  'rose-pine',
  'kanagawa',
  'everforest',
  'monokai-pro',
}

local statefile = vim.fn.stdpath 'state' .. '/last-colorscheme.txt'

local variant_handlers = {
  ['tokyonight-night'] = function()
    vim.g.tokyonight_style = 'night'
    vim.cmd.colorscheme 'tokyonight'
  end,
  ['catppuccin-mocha'] = function()
    vim.g.catppuccin_flavour = 'mocha'
    vim.cmd.colorscheme 'catppuccin'
  end,
}

local function is_installed(name)
  local base = name:match '^[^%-]+'
  return vim.fn.empty(vim.fn.globpath(vim.o.rtp, 'colors/' .. name .. '.vim')) == 0
    or vim.fn.empty(vim.fn.globpath(vim.o.rtp, 'colors/' .. name .. '.lua')) == 0
    or vim.fn.empty(vim.fn.globpath(vim.o.rtp, 'colors/' .. base .. '.vim')) == 0
    or vim.fn.empty(vim.fn.globpath(vim.o.rtp, 'colors/' .. base .. '.lua')) == 0
end

local installed = vim.tbl_filter(is_installed, favorites)

function M.load_last()
  if vim.fn.filereadable(statefile) == 1 then
    local scheme = vim.fn.readfile(statefile)[1]
    if scheme and scheme ~= '' then
      local handler = variant_handlers[scheme]
      if handler then
        handler()
      elseif is_installed(scheme) then
        vim.cmd.colorscheme(scheme)
      end
    end
  end
end

local function save_scheme(scheme)
  vim.fn.writefile({ scheme }, statefile)
end

function M.pick()
  local telescope_ok = pcall(require, 'telescope')
  if not telescope_ok then
    vim.notify('❌ telescope.nvim not found', vim.log.levels.ERROR)
    return
  end

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  pickers
    .new({}, {
      prompt_title = '🎨 Choose Colorscheme',
      finder = finders.new_table { results = installed },
      sorter = conf.generic_sorter {},
      attach_mappings = function(_, map)
        local function apply_and_save()
          local entry = action_state.get_selected_entry()
          if not entry then
            return
          end

          local scheme = entry.value
          local handler = variant_handlers[scheme]
          if handler then
            handler()
          else
            vim.cmd.colorscheme(scheme)
          end

          save_scheme(scheme)
          -- 🚫 Don't call actions.close()
          return true -- allow Telescope to close normally
        end

        map('i', '<CR>', apply_and_save)
        map('n', '<CR>', apply_and_save)
        return true
      end,
    })
    :find()
end

return M
