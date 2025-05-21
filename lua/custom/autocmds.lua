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

      vim.keymap.set('n', 'r', function() -- Seek -5s (backward)
        mpv_cmd { 'no-osd', 'seek', -5, 'exact' }
      end, { buffer = args.buf, desc = 'Seek -5s in MPV' })

      vim.keymap.set('n', 'c', function() -- Seek +5s (forward)
        mpv_cmd { 'no-osd', 'seek', 5, 'exact' }
      end, { buffer = args.buf, desc = 'Seek +5s in MPV' })

      vim.keymap.set('n', 'h', function() -- Next chapter
        mpv_cmd { 'script-message', 'chapter_controls/jump_next_chapter' }
      end, { buffer = args.buf, desc = 'Next chapter in MPV' })

      vim.keymap.set('n', 'H', function() -- Last chapter
        mpv_cmd { 'script-message', 'chapter_controls/jump_last_chapter' }
      end, { buffer = args.buf, desc = 'Next chapter in MPV' })

      vim.keymap.set('n', 't', function() -- Nudge chapter later
        mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_later' }
      end, { buffer = args.buf, desc = 'Nudge chapter later' })

      vim.keymap.set('n', 'n', function() -- Nudge chapter earlier
        mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_earlier' }
      end, { buffer = args.buf, desc = 'Nudge chapter earlier' })

      vim.keymap.set('n', 's', function() -- Previous chapter
        mpv_cmd { 'script-message', 'chapter_controls/jump_previous_chapter' }
      end, { buffer = args.buf, desc = 'Previous chapter in MPV' })

      vim.keymap.set('n', 'S', function() -- Last chapter
        mpv_cmd { 'script-message', 'chapter_controls/jump_first_chapter' }
      end, { buffer = args.buf, desc = 'Next chapter in MPV' })

      vim.keymap.set('n', 'z', function() -- Remove chapter
        mpv_cmd { 'script-message', 'chapters/remove_chapter' }
      end, { buffer = args.buf, desc = 'Remove current chapter' })

      vim.keymap.set('n', 'g', function() -- Write chapters
        mpv_cmd { 'script-message', 'chapters/write_chapters' }
      end, { buffer = args.buf, desc = 'Write chapters' })

      vim.keymap.set('n', '-', function() -- Pause/play (cycle pause)
        mpv_cmd { 'cycle', 'pause' }
      end, { buffer = args.buf, desc = 'Toggle MPV pause' })

      vim.keymap.set('n', 'd', function() -- Show progress
        mpv_cmd { 'show-progress' }
      end, { buffer = args.buf, desc = 'Show MPV progress' })

      vim.keymap.set('n', 'm', function() -- Add chapter
        local line = vim.api.nvim_get_current_line()
        mpv_cmd { 'script-message', 'chapters/add-chapter', line:sub(1, 120) }
      end, { buffer = args.buf, desc = 'Add chapter to MPV from current line' })

      vim.keymap.set('n', 'w', 'k', { buffer = args.buf, desc = 'Move cursor up one line' })
      vim.keymap.set('n', 'v', 'j', { buffer = args.buf, desc = 'Move cursor down one line' })
    end
  end,
})

--[[
Key  | MPV Action/Description                         | MPV Command or Vim Action
-----|------------------------------------------------|-----------------------------------------------
}    | Volume up                                      | add volume 2
]    | Volume down                                    | add volume -2
g    | Write chapters                                 | script-message chapters/write_chapters
c    | Seek +5s (forward)                             | no-osd seek 5 exact
r    | Seek -5s (backward)                            | no-osd seek -5 exact
h    | Next chapter                                   | script-message chapter_controls/jump_next_chapter
H    | Last chapter                                   | script-message chapter_controls/jump_last_chapter
t    | Nudge chapter later                            | script-message chapter_controls/nudge_chapter_later
n    | Nudge chapter earlier                          | script-message chapter_controls/nudge_chapter_earlier
s    | Previous chapter                               | script-message chapter_controls/jump_previous_chapter
S    | First chapter                                  | script-message chapter_controls/jump_first_chapter
-    | Toggle pause/play                              | cycle pause
d    | Show progress                                  | show-progress
m    | Add chapter with current line                  | script-message chapters/add-chapter <line>
z    | Remove current chapter                         | script-message chapters/remove_chapter
w    | Move cursor up one line (Vim)                  | k
v    | Move cursor down one line (Vim)                | j

Location: These keymaps are only active in .txt buffers under ~/utono/literature/**
]]
