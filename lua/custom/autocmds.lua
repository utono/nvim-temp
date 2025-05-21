-- Minimal pure-Lua base64 encode
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
    -- Expand ~/ to home directory
    local home = vim.fn.expand '~'
    if fname:find(home .. '/utono/literature/', 1, true) == 1 then
      -- Only apply for files in ~/utono/literature and subdirs
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.scrolloff = 999
      vim.cmd 'highlight Normal guibg=#000000 guifg=#ffffff'
      vim.cmd 'highlight NormalNC guibg=#000000 guifg=#ffffff'
      vim.cmd 'highlight SignColumn guibg=#000000 guifg=#ffffff'
      vim.cmd 'highlight VertSplit guibg=#000000'

      local mpv_socket = '/tmp/mpvsocket'
      local function mpv_cmd(tbl)
        local json = vim.fn.json_encode { command = tbl }
        vim.fn.jobstart { 'sh', '-c', string.format("echo '%s' | socat - %s", json, mpv_socket) }
      end

      vim.keymap.set('n', '}', function() -- Volume up
        mpv_cmd { 'add', 'volume', 2 }
      end, { buffer = args.buf, desc = 'Increase MPV volume' })

      vim.keymap.set('n', ']', function() -- Volume down
        mpv_cmd { 'add', 'volume', -2 }
      end, { buffer = args.buf, desc = 'Decrease MPV volume' })

      vim.keymap.set('n', 'g', function() -- Previous chapter
        mpv_cmd { 'script-message', 'chapter_controls/jump_previous_chapter' }
      end, { buffer = args.buf, desc = 'Previous chapter in MPV' })

      vim.keymap.set('n', 'G', function() -- Last chapter
        mpv_cmd { 'script-message', 'chapter_controls/jump_first_chapter' }
      end, { buffer = args.buf, desc = 'Next chapter in MPV' })

      vim.keymap.set('n', 'c', 'k', { buffer = args.buf, desc = 'Move cursor up one line' })
      vim.keymap.set('n', 'r', 'j', { buffer = args.buf, desc = 'Move cursor down one line' })

      vim.keymap.set('n', 'l', function() -- Next chapter
        mpv_cmd { 'script-message', 'chapter_controls/jump_next_chapter' }
      end, { buffer = args.buf, desc = 'Next chapter in MPV' })

      vim.keymap.set('n', 'L', function() -- Last chapter
        mpv_cmd { 'script-message', 'chapter_controls/jump_last_chapter' }
      end, { buffer = args.buf, desc = 'Next chapter in MPV' })

      vim.keymap.set('n', 'h', function()
        local line = vim.api.nvim_get_current_line()
        local b64 = base64enc(line)
        mpv_cmd { 'script-message', 'chapters/add-chapter-b64', b64 }
      end, { buffer = args.buf, desc = 'Add chapter to MPV from current line (base64-safe)' })

      vim.keymap.set('n', 't', function() -- Seek -5s (backward)
        mpv_cmd { 'no-osd', 'seek', -5, 'exact' }
      end, { buffer = args.buf, desc = 'Seek -5s in MPV' })

      vim.keymap.set('n', 'n', function() -- Seek +5s (forward)
        mpv_cmd { 'no-osd', 'seek', 5, 'exact' }
      end, { buffer = args.buf, desc = 'Seek +5s in MPV' })

      vim.keymap.set('n', 's', function() -- Pause/play (cycle pause)
        mpv_cmd { 'cycle', 'pause' }
      end, { buffer = args.buf, desc = 'Toggle MPV pause' })

      vim.keymap.set('n', 'd', function() -- Show progress
        mpv_cmd { 'show-progress' }
      end, { buffer = args.buf, desc = 'Show MPV progress' })

      vim.keymap.set('n', 'm', function() -- Write chapters
        mpv_cmd { 'script-message', 'chapters/write_chapters' }
      end, { buffer = args.buf, desc = 'Write chapters' })

      vim.keymap.set('n', 'w', function() -- Nudge chapter earlier
        mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_earlier' }
      end, { buffer = args.buf, desc = 'Nudge chapter earlier' })

      vim.keymap.set('n', 'v', function() -- Nudge chapter later
        mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_later' }
      end, { buffer = args.buf, desc = 'Nudge chapter later' })

      vim.keymap.set('n', 'z', function() -- Remove chapter
        mpv_cmd { 'script-message', 'chapters/remove_chapter' }
      end, { buffer = args.buf, desc = 'Remove current chapter' })
    end
  end,
})

--[[
Key  | MPV Action/Description                         | MPV Command or Vim Action
-----|------------------------------------------------|-----------------------------------------------
}    | Volume up                                      | add volume 2
]    | Volume down                                    | add volume -2
g    | Previous chapter                               | script-message chapter_controls/jump_previous_chapter
G    | First chapter                                  | script-message chapter_controls/jump_first_chapter
c    | Move cursor up one line (Vim)                  | k
r    | Move cursor down one line (Vim)                | j
h    | Add chapter with current line                  | script-message chapters/add-chapter <line>
l    | Next chapter                                   | script-message chapter_controls/jump_next_chapter
L    | Last chapter                                   | script-message chapter_controls/jump_last_chapter
t    | Seek -5s (backward)                            | no-osd seek -5 exact
n    | Seek +5s (forward)                             | no-osd seek 5 exact
s    | Toggle pause/play                              | cycle pause
d    | Show progress                                  | show-progress
m    | Write chapters                                 | script-message chapters/write_chapters
w    | Nudge chapter earlier                          | script-message chapter_controls/nudge_chapter_earlier
v    | Nudge chapter later                            | script-message chapter_controls/nudge_chapter_later
z    | Remove current chapter                         | script-message chapters/remove_chapter

Location: These keymaps are only active in .txt buffers under ~/utono/literature/**
]]
