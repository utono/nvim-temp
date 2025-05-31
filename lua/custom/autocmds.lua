-- [[ Custom Autocommands for .txt files in ~/utono/literature/ ]]
--
-- This section is only triggered for .txt files under ~/utono/literature/**
-- It disables line numbers, sets infinite scrolloff, and establishes
-- buffer-local keymaps for integration with MPV.
-- All other global autocommands should be in kickstart/plugins/autocmds.lua.
--
-- Keymaps are grouped and ordered to match physical real_prog_dvorak layout

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
    -- OVERRIDE: Skip all customizations if override is set
    if vim.env.LITERATURE_OVERRIDE == '1' then
      return
    end

    local fname = vim.api.nvim_buf_get_name(args.buf)
    local home = vim.fn.expand '~'
    if fname:find(home .. '/utono/literature/', 1, true) ~= 1 then
      return
    end
    -- ... rest of your code

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

    vim.keymap.set('v', 'o', [[:<C-u>lua require('custom.gloss').gloss_selection()<CR>]], {
      buffer = args.buf,
      desc = 'Gloss selected Shakespeare text (Arden style)',
      silent = true,
    })

    set('n', '+', function()
      mpv_cmd { 'add', 'speed', 0.1 }
    end, 'Increase MPV speed by 0.1')

    set('n', '[', function()
      mpv_cmd { 'script-message', 'chapter_controls/jump_previous_chapter' }
    end, 'Previous chapter')
    set('n', '2', function()
      mpv_cmd { 'script-message', 'chapter_controls/jump_first_chapter' }
    end, 'First chapter')
    set('n', '{', function()
      mpv_cmd { 'script-message', 'chapter_controls/jump_next_chapter' }
    end, 'Next chapter')
    set('n', '3', function()
      mpv_cmd { 'script-message', 'chapter_controls/jump_last_chapter' }
    end, 'Last chapter')

    -- set('n', '}', function()
    --   mpv_cmd { 'script-message', 'chapter_controls/jump_previous_chapter' }
    -- end, 'Previous chapter')
    -- set('n', '8', function()
    --   mpv_cmd { 'script-message', 'chapter_controls/jump_first_chapter' }
    -- end, 'First chapter')
    -- set('n', ']', function()
    --   mpv_cmd { 'script-message', 'chapter_controls/jump_next_chapter' }
    -- end, 'Next chapter')
    -- set('n', '9', function()
    --   mpv_cmd { 'script-message', 'chapter_controls/jump_last_chapter' }
    -- end, 'Last chapter')

    set('n', '<Tab>', function()
      mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_earlier' }
    end, 'Nudge chapter earlier')
    set('n', ',', 'j', 'Move cursor down one line')
    set('n', '.', 'k', 'Move cursor up one line')
    set('n', 'y', function()
      mpv_cmd { 'script-message', 'dynamic_chapter_loop/toggle' }
    end, 'Toggle chapter loop')

    -- set('n', 'g', function()
    --   mpv_cmd { 'no-osd', 'seek', -5, 'exact' }
    -- end, 'Seek -5s in MPV')
    -- set('n', 'c', 'k', 'Move cursor up one line')
    -- set('n', 'r', 'j', 'Move cursor down one line')
    -- set('n', 'l', function()
    --   mpv_cmd { 'no-osd', 'seek', 5, 'exact' }
    -- end, 'Seek +5s in MPV')

    -- set('n', '\\', function()
    --   mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_later' }
    -- end, 'Nudge chapter later')

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

    set('n', 'i', function()
      mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_later' }
    end, 'Nudge chapter later')
    -- set('n', 'd', function()
    --   mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_earlier' }
    -- end, 'Show MPV progress')
    -- set('n', 'h', function()
    --   local line = vim.api.nvim_get_current_line()
    --   mpv_cmd { 'script-message', 'chapters/add-chapter-b64', base64enc(line) }
    -- end, 'Add chapter (base64) to MPV (current line)')
    -- set('n', 's', function()
    --   mpv_cmd { 'cycle', 'pause' }
    -- end, 'Toggle MPV pause')

    set('n', '-', function()
      mpv_cmd { 'add', 'speed', -0.1 }
    end, 'Decrease MPV speed by 0.1')

    set('n', "'", function()
      mpv_cmd { 'script-message', 'chapters/remove_chapter' }
    end, 'Remove chapter')
    set('n', 'm', function()
      mpv_cmd { 'script-message', 'chapters/write_chapters' }
    end, 'Write chapters')
    -- set('n', 'z', function()
    --   mpv_cmd { 'script-message', 'chapters/remove_chapter' }
    -- end, 'Remove chapter')

    set('n', '<leader>', function()
      mpv_cmd { 'cycle', 'pause' }
    end, 'Toggle MPV pause')
    -- Optional: Add more keymaps as needed
  end,
})

-- Neo-tree auto open on VimEnter (if desired)
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Check all buffers for files matching ~/utono/literature/*.txt
    local home = vim.fn.expand '~'
    local ignore_neotree = false

    -- Get list of files passed on command line, or currently opened
    -- (For Neovim >=0.7, use vim.v.argv for command line args)
    local buffers = vim.api.nvim_list_bufs()
    for _, buf in ipairs(buffers) do
      local fname = vim.api.nvim_buf_get_name(buf)
      if fname ~= '' and fname:sub(1, #home + 18) == home .. '/utono/literature/' and fname:sub(-4) == '.txt' then
        ignore_neotree = true
        break
      end
    end

    if not ignore_neotree then
      require('neo-tree.command').execute { action = 'hide', source = 'filesystem' }
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.md',
  callback = function()
    vim.opt_local.scrolloff = 999
  end,
})
