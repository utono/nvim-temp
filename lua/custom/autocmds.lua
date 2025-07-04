-- ~/.config/nvim/lua/custom/autocmds.lua
--
-- [[ Custom Autocommands for .txt files in ~/utono/literature/ ]]
-- Integrates MPV controls via mpv-control plugin, disables distractions.

local mpv = require 'custom.mpv-control'
local home = vim.env.HOME

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.txt',
  callback = function(args)
    if vim.env.LITERATURE_OVERRIDE == '1' then
      return
    end
    local fname = vim.api.nvim_buf_get_name(args.buf)
    if fname:find(home .. '/utono/literature/', 1, true) ~= 1 then
      return
    end

    local b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local function base64enc(data)
      return (
        (data:gsub('.', function(x)
          local r, b = '', x:byte()
          for i = 8, 1, -1 do
            r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
          end
          return r
        end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
          if #x < 6 then
            return ''
          end
          local c = 0
          for i = 1, 6 do
            c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
          end
          return b64:sub(c + 1, c + 1)
        end) .. ({ '', '==', '=' })[#data % 3 + 1]
      )
    end

    local set = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
    end

    if vim.g.neovide then
      set('n', 'n', 'n', 'Search forward')
    end

    set('n', '+', function()
      mpv.send { 'add', 'speed', 0.1 }
    end, 'Increase speed')
    set('n', '-', function()
      mpv.send { 'add', 'speed', -0.1 }
    end, 'Decrease speed')
    set('n', '<Right>', function()
      mpv.send { 'add', 'volume', 5 }
    end, 'Increase volume')
    set('n', '<Left>', function()
      mpv.send { 'add', 'volume', -5 }
    end, 'Decrease volume')
    set('n', '[', function()
      mpv.send { 'script-message', 'chapter_controls/jump_previous_chapter' }
    end, 'Prev chapter')
    set('n', '2', function()
      mpv.send { 'script-message', 'chapter_controls/jump_first_chapter' }
    end, 'First chapter')
    set('n', '{', function()
      mpv.send { 'script-message', 'chapter_controls/jump_next_chapter' }
    end, 'Next chapter')
    set('n', '3', function()
      mpv.send { 'script-message', 'chapter_controls/jump_last_chapter' }
    end, 'Last chapter')
    set('n', '&', function()
      mpv.send { 'cycle', 'mute' }
    end, 'Toggle mute')
    set('n', ']', function()
      mpv.send { 'script-message', 'chapter_controls/jump_previous_chapter' }
    end, 'Prev chapter')
    set('n', '9', function()
      mpv.send { 'script-message', 'chapter_controls/jump_first_chapter' }
    end, 'First chapter')
    set('n', '}', function()
      mpv.send { 'script-message', 'chapter_controls/jump_next_chapter' }
    end, 'Next chapter')
    set('n', '8', function()
      mpv.send { 'script-message', 'chapter_controls/jump_last_chapter' }
    end, 'Last chapter')
    set('n', '<Tab>', function()
      mpv.send { 'script-message', 'chapter_controls/nudge_chapter_earlier' }
    end, 'Nudge earlier')
    set('n', '\\', function()
      mpv.send { 'script-message', 'chapter_controls/nudge_chapter_earlier' }
    end, 'Nudge earlier')
    set('n', ',', function()
      mpv.send { 'script-message', 'loop_duration/shift' }
    end, 'loopduration toggle')
    set('n', '<', function()
      mpv.send { 'script-message', 'loop_duration/toggle' }
    end, 'loopduration toggle')
    set('n', 'p', function()
      mpv.send { 'script-message', 'chapters/write_chapters' }
    end, 'Write chapters')
    set('n', 'f', function()
      mpv.send { 'script-message', 'dynamic_chapter_loop/toggle' }
    end, 'Toggle loop')
    set('n', 'c', function()
      mpv.send { 'script-message', 'loop_duration/toggle' }
    end, 'loopduration toggle')
    set('n', 'r', function()
      mpv.send { 'script-message', 'loop_duration/shift' }
    end, 'loopduration toggle')
    set('n', 'a', function()
      mpv.send { 'cycle', 'pause' }
    end, 'Toggle pause')
    set('n', 'o', function()
      mpv.send { 'no-osd', 'seek', -5, 'exact' }
    end, 'Seek -5s')
    set('n', 'O', function()
      mpv.send { 'no-osd', 'seek', -10, 'exact' }
    end, 'Seek -10s')
    set('n', 'e', function()
      mpv.send { 'no-osd', 'seek', 5, 'exact' }
    end, 'Seek +5s')
    set('n', 'E', function()
      mpv.send { 'no-osd', 'seek', 10, 'exact' }
    end, 'Seek +10s')
    set('n', 'u', function()
      local line = vim.api.nvim_get_current_line()
      mpv.send { 'script-message', 'chapters/add-chapter-b64', base64enc(line) }
    end, 'Add chapter')
    set('n', 'i', function()
      mpv.send { 'script-message', 'chapter_controls/nudge_chapter_later' }
    end, 'Nudge later')
    set('n', 'd', function()
      mpv.send { 'script-message', 'chapter_controls/nudge_chapter_later' }
    end, 'Nudge later')
    set('n', 'h', function()
      local line = vim.api.nvim_get_current_line()
      mpv.send { 'script-message', 'chapters/add-chapter-b64', base64enc(line) }
    end, 'Add chapter')
    -- set('n', 't', function()
    --   mpv.send { 'no-osd', 'seek', 5, 'exact' }
    -- end, 'Seek +5s')
    -- set('n', 'T', function()
    --   mpv.send { 'no-osd', 'seek', 10, 'exact' }
    -- end, 'Seek +10s')
    set('n', 't', function()
      mpv.send { 'no-osd', 'seek', -5, 'exact' }
    end, 'Seek -5s')
    set('n', 'T', function()
      mpv.send { 'no-osd', 'seek', 5, 'exact' }
    end, 'Seek +5s')
    -- set('n', 'n', function()
    --   mpv.send { 'no-osd', 'seek', -5, 'exact' }
    -- end, 'Seek -5s')
    -- set('n', 'N', function()
    --   mpv.send { 'no-osd', 'seek', -10, 'exact' }
    -- end, 'Seek -10s')
    set('n', 's', function()
      mpv.send { 'cycle', 'pause' }
    end, 'Toggle pause')
    set('n', "'", function()
      mpv.send { 'script-message', 'chapters/remove_chapter' }
    end, 'Remove chapter')
    set('n', 'm', 'k', 'Move cursor up')
    set('n', 'w', 'j', 'Move cursor down')
    set('n', '<Down>', ':cnext<CR>', 'Next quickfix (Zen Mode)')
    set('n', '<Up>', ':cprevious<CR>', 'Previous quickfix (Zen Mode)')

    vim.keymap.set('v', 'o', [[:<C-u>lua require('custom.gloss').gloss_selection()<CR>]], {
      buffer = args.buf,
      desc = 'Gloss selected Shakespeare text (Arden style)',
      silent = true,
    })

    vim.keymap.set('n', '<Esc>', function()
      vim.cmd.nohlsearch()
      local col = vim.fn.col '.'
      local first_nonblank = vim.fn.col '^'
      if col ~= first_nonblank then
        vim.cmd.normal { '^', bang = true }
      end
    end, { buffer = args.buf, desc = 'Clear search & move to ^' })

    vim.opt_local.hlsearch = false
    vim.api.nvim_create_autocmd('CmdlineEnter', {
      buffer = args.buf,
      callback = function()
        if vim.v.event.cmdtype == '/' or vim.v.event.cmdtype == '?' then
          vim.opt_local.hlsearch = true
        end
      end,
    })

    vim.api.nvim_create_autocmd('CmdlineLeave', {
      buffer = args.buf,
      callback = function()
        if vim.v.event.cmdtype == '/' or vim.v.event.cmdtype == '?' then
          vim.defer_fn(function()
            vim.opt_local.hlsearch = false
            vim.cmd 'echo'
          end, 100)
        end
      end,
    })

    vim.api.nvim_create_autocmd('ModeChanged', {
      buffer = args.buf,
      group = vim.api.nvim_create_augroup('LiteratureCursorAdjust', { clear = false }),
      callback = function()
        if vim.fn.mode() == 'n' then
          local col = vim.fn.col '.'
          local first_nonblank = vim.fn.col '^'
          if col ~= first_nonblank then
            vim.cmd.normal { '^', bang = true }
          end
        end
      end,
    })
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Clear yank message in Neovide Zen Mode',
  group = vim.api.nvim_create_augroup('neovide_zen_clear_yank', { clear = true }),
  callback = function()
    if vim.g.neovide and require('zen-mode.view').is_open() then
      vim.defer_fn(function()
        vim.cmd 'echo'
      end, 1000)
    end
  end,
})

local previous_colorscheme

vim.api.nvim_create_autocmd('User', {
  pattern = 'ZenModeEnter',
  callback = function()
    if not vim.g.neovide then
      return
    end

    local file = vim.api.nvim_buf_get_name(0)
    if file:find('^' .. vim.fn.expand '~/utono/literature/') then
      previous_colorscheme = vim.g.colors_name
      vim.cmd.colorscheme 'gruvbox-material'
    end
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'ZenModeLeave',
  callback = function()
    if not vim.g.neovide then
      return
    end

    if previous_colorscheme then
      vim.cmd.colorscheme(previous_colorscheme)
    end
  end,
})
