-- [[ Custom Autocommands for .txt files in ~/utono/literature/ ]]
--
-- This section is only triggered for .txt files under ~/utono/literature/**
-- It disables line numbers, sets infinite scrolloff, and establishes
-- buffer-local keymaps for integration with MPV.
-- All other global autocommands should be in kickstart/plugins/autocmds.lua.

local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
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
      return b:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1]
  )
end

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.txt',
  callback = function(args)
    local fname = vim.api.nvim_buf_get_name(args.buf)
    local home = vim.fn.expand '~'
    if fname:find(home .. '/utono/literature/', 1, true) ~= 1 then
      return
    end

    -- Buffer-local options
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.scrolloff = 999

    -- Optional: Black/white color scheme for distraction-free mode
    vim.cmd 'highlight Normal guibg=#000000 guifg=#ffffff'
    vim.cmd 'highlight NormalNC guibg=#000000 guifg=#ffffff'
    vim.cmd 'highlight SignColumn guibg=#000000 guifg=#ffffff'
    vim.cmd 'highlight VertSplit guibg=#000000'

    local mpv_socket = '/tmp/mpvsocket'
    local function mpv_cmd(tbl)
      local json = vim.fn.json_encode { command = tbl }
      vim.fn.jobstart { 'sh', '-c', string.format("echo '%s' | socat - %s", json, mpv_socket) }
    end

    -- Keymaps for quick navigation and MPV integration
    local set = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
    end

    set('n', ',', 'j', 'Move cursor down one line')
    set('n', '.', 'k', 'Move cursor up one line')
    set('n', 'a', function()
      mpv_cmd { 'cycle', 'pause' }
    end, 'Toggle MPV pause')
    set('n', 'o', function()
      mpv_cmd { 'no-osd', 'seek', -5, 'exact' }
    end, 'Seek -5s in MPV')
    set('n', 'e', function()
      mpv_cmd { 'no-osd', 'seek', 5, 'exact' }
    end, 'Seek +5s in MPV')
    set('n', 'u', function()
      local line = vim.api.nvim_get_current_line()
      mpv_cmd { 'script-message', 'chapters/add-chapter-b64', base64enc(line) }
    end, 'Add chapter (base64) to MPV (current line)')
    set('n', '}', function()
      mpv_cmd { 'script-message', 'chapter_controls/jump_previous_chapter' }
    end, 'Previous chapter')
    set('n', '8', function()
      mpv_cmd { 'script-message', 'chapter_controls/jump_first_chapter' }
    end, 'First chapter')
    set('n', ']', function()
      mpv_cmd { 'script-message', 'chapter_controls/jump_next_chapter' }
    end, 'Next chapter')
    set('n', '9', function()
      mpv_cmd { 'script-message', 'chapter_controls/jump_last_chapter' }
    end, 'Last chapter')
    set('n', 'c', 'k', 'Move cursor up one line')
    set('n', 'r', 'j', 'Move cursor down one line')
    set('n', 'g', function()
      mpv_cmd { 'no-osd', 'seek', -5, 'exact' }
    end, 'Seek -5s in MPV')
    set('n', 'l', function()
      mpv_cmd { 'no-osd', 'seek', 5, 'exact' }
    end, 'Seek +5s in MPV')
    set('n', 'd', function()
      mpv_cmd { 'show-progress' }
    end, 'Show MPV progress')
    set('n', 'h', function()
      local line = vim.api.nvim_get_current_line()
      mpv_cmd { 'script-message', 'chapters/add-chapter-b64', base64enc(line) }
    end, 'Add chapter (base64) to MPV (current line)')
    set('n', 's', function()
      mpv_cmd { 'cycle', 'pause' }
    end, 'Toggle MPV pause')
    set('n', 'm', function()
      mpv_cmd { 'script-message', 'chapters/write_chapters' }
    end, 'Write chapters')
    set('n', 'w', function()
      mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_earlier' }
    end, 'Nudge chapter earlier')
    set('n', 'v', function()
      mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_later' }
    end, 'Nudge chapter later')
    set('n', 'z', function()
      mpv_cmd { 'script-message', 'chapters/remove_chapter' }
    end, 'Remove chapter')

    -- Optional: Add more keymaps as needed
  end,
})

-- Neo-tree auto open on VimEnter (if desired)
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    require('neo-tree.command').execute { action = 'show', source = 'filesystem' }
  end,
})
