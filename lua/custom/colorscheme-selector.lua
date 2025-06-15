-- File: ~/.config/nvim/lua/custom/colorscheme-selector.lua

local M = {}

local favorites = {
  'gruvbox-material',
  'gruvbox',
  'catppuccin-mocha',
  'tokyonight-night',
  'rose-pine',
}

local statefile = vim.fn.stdpath 'state' .. '/last-colorscheme.txt'
local current_index = nil

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

local function save_scheme(scheme)
  vim.fn.writefile({ scheme }, statefile)
end

local function apply_scheme_by_index(index)
  local scheme = favorites[index]
  if not scheme then
    return
  end

  local handler = variant_handlers[scheme]
  if handler then
    handler()
  else
    vim.cmd.colorscheme(scheme)
  end

  save_scheme(scheme)
  vim.defer_fn(function()
    vim.notify(string.format('Colorscheme: %s (%d/%d)', scheme, index, #favorites), vim.log.levels.INFO)
  end, 20)
end

local function find_current_index()
  local current = vim.g.colors_name or ''
  for i, name in ipairs(favorites) do
    if current == name or current == name:match '^[^%-]+' then
      return i
    end
  end
  return 1
end

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

function M.pick()
  local ok = pcall(require, 'telescope')
  if not ok then
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
      attach_mappings = function(prompt_bufnr, map)
        local function apply_and_save()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          if not entry then
            return
          end

          local scheme = entry.value
          local index = vim.tbl_indexof(favorites, scheme) or 0

          local handler = variant_handlers[scheme]
          if handler then
            handler()
          else
            vim.cmd.colorscheme(scheme)
          end

          save_scheme(scheme)
          vim.defer_fn(function()
            vim.notify(string.format('Colorscheme: %s (%d/%d)', scheme, index, #favorites), vim.log.levels.INFO)
          end, 20)
        end

        map('i', '<CR>', apply_and_save)
        map('n', '<CR>', apply_and_save)
        return true
      end,
    })
    :find()
end

function M.cycle()
  current_index = current_index or find_current_index()
  current_index = (current_index % #favorites) + 1
  apply_scheme_by_index(current_index)
end

function M.cycle_back()
  current_index = current_index or find_current_index()
  current_index = ((current_index - 2 + #favorites) % #favorites) + 1
  apply_scheme_by_index(current_index)
end

return M
