-- ~/.config/nvim/lua/custom/autocmds.lua
--
-- [[ Custom Autocommands for .txt files in ~/utono/literature/ ]]
-- Integrates MPV controls, disables global UI distractions, and assumes
-- Zen Mode handles visual presentation.
-- Keymaps are grouped and ordered to match physical real_prog_dvorak layout

local home = os.getenv 'HOME'

local function get_mpv_socket()
  local handle = io.popen 'ls /tmp/mpvsocket-* 2>/dev/null'
  if not handle then
    return nil
  end
  for socket_path in handle:read('*a'):gmatch '[^\n]+' do
    local cmd = string.format([[echo '{"command":["get_property","path"]}' | socat - UNIX-CONNECT:%s]], socket_path)
    local out = io.popen(cmd)
    if out then
      local result = out:read '*a'
      out:close()
      if result and result:match '%S' then
        local decoded = vim.fn.json_decode(result)
        local path = decoded and decoded.data
        if path and (path:find(home .. '/Music') or path:find(home .. '/rips')) then
          return socket_path
        end
      end
    end
  end
  return nil
end

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

    local function mpv_cmd(tbl)
      local socket = get_mpv_socket()
      if not socket then
        vim.notify('MPV socket not found for ~/Music or ~/rips', vim.log.levels.WARN)
        return
      end
      local json = vim.fn.json_encode { command = tbl }
      vim.fn.jobstart { 'sh', '-c', string.format("echo '%s' | socat - UNIX-CONNECT:%s", json, socket) }
    end

    local set = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
    end

    -- Chapter, seek, pause, and volume keymaps
    set('n', '+', function()
      mpv_cmd { 'add', 'speed', 0.1 }
    end, 'Increase speed')
    set('n', '-', function()
      mpv_cmd { 'add', 'speed', -0.1 }
    end, 'Decrease speed')
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
    set('n', '&', function()
      mpv_cmd { 'cycle', 'mute' }
    end, 'Toggle mute')
    set('n', '<Tab>', function()
      mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_earlier' }
    end, 'Nudge earlier')
    set('n', ',', function()
      mpv_cmd { 'script-message', 'chapter_controls/jump_previous_chapter' }
    end, 'Previous chapter')
    set('n', '<', function()
      mpv_cmd { 'script-message', 'chapter_controls/jump_first_chapter' }
    end, 'First chapter')
    set('n', '.', function()
      mpv_cmd { 'script-message', 'chapter_controls/jump_next_chapter' }
    end, 'Next chapter')
    set('n', '>', function()
      mpv_cmd { 'script-message', 'chapter_controls/jump_last_chapter' }
    end, 'Last chapter')
    set('n', 'p', function()
      mpv_cmd { 'script-message', 'dynamic_chapter_loop/toggle' }
    end, 'Toggle loop')
    set('n', 'a', function()
      mpv_cmd { 'cycle', 'pause' }
    end, 'Toggle pause')
    set('n', 'o', function()
      mpv_cmd { 'no-osd', 'seek', -5, 'exact' }
    end, 'Seek -5s')
    set('n', 'O', function()
      mpv_cmd { 'no-osd', 'seek', -10, 'exact' }
    end, 'Seek -10s')
    set('n', 'e', function()
      mpv_cmd { 'no-osd', 'seek', 5, 'exact' }
    end, 'Seek +5s')
    set('n', 'E', function()
      mpv_cmd { 'no-osd', 'seek', 10, 'exact' }
    end, 'Seek +10s')
    set('n', 'u', function()
      mpv_cmd { 'script-message', 'chapters/add-chapter-b64', base64enc(vim.api.nvim_get_current_line()) }
    end, 'Add chapter')
    set('n', 'i', function()
      mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_later' }
    end, 'Nudge later')
    set('n', "'", function()
      mpv_cmd { 'script-message', 'chapters/remove_chapter' }
    end, 'Remove chapter')
    set('n', 'q', function()
      mpv_cmd { 'script-message', 'chapters/write_chapters' }
    end, 'Write chapters')
    set('n', 'm', function()
      mpv_cmd { 'script-message', 'chapters/write_chapters' }
    end, 'Write chapters')
    set('n', '<Down>', function()
      mpv_cmd { 'add', 'volume', -2 }
    end, 'Volume down')
    set('n', '<Up>', function()
      mpv_cmd { 'add', 'volume', 2 }
    end, 'Volume up')

    -- Shakespeare gloss keybind
    vim.keymap.set('v', 'o', [[:<C-u>lua require('custom.gloss').gloss_selection()<CR>]], {
      buffer = args.buf,
      desc = 'Gloss selected Shakespeare text (Arden style)',
      silent = true,
    })

    -- Clear search highlight with <Esc>
    vim.keymap.set('n', '<Esc>', function()
      vim.cmd.nohlsearch()
      local col = vim.fn.col '.'
      local first_nonblank = vim.fn.col '^'
      if col ~= first_nonblank then
        vim.cmd.normal { '^', bang = true }
      end
    end, { buffer = args.buf, desc = 'Clear search & move to ^' })

    -- Smart hlsearch only while searching
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

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.md',
  callback = function()
    vim.opt_local.scrolloff = 999
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
