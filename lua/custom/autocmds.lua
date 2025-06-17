-- ~/.config/nvim/lua/custom/autocmds.lua
--
-- Custom Autocommands for .txt files in ~/utono/literature/
-- Integrates MPV controls using dynamic IPC socket discovery.

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

    set('n', '+', function()
      mpv_cmd { 'add', 'speed', 0.1 }
    end, 'Increase MPV speed')
    set('n', '-', function()
      mpv_cmd { 'add', 'speed', -0.1 }
    end, 'Decrease MPV speed')
    set('n', 'a', function()
      mpv_cmd { 'cycle', 'pause' }
    end, 'Toggle pause')
    set('n', 'o', function()
      mpv_cmd { 'no-osd', 'seek', -3, 'exact' }
    end, 'Seek -3s')
    set('n', 'e', function()
      mpv_cmd { 'no-osd', 'seek', 3, 'exact' }
    end, 'Seek +3s')
    set('n', 'O', function()
      mpv_cmd { 'no-osd', 'seek', -10, 'exact' }
    end, 'Seek -10s')
    set('n', 'E', function()
      mpv_cmd { 'no-osd', 'seek', 10, 'exact' }
    end, 'Seek +10s')
    set('n', 'u', function()
      local line = vim.api.nvim_get_current_line()
      mpv_cmd { 'script-message', 'chapters/add-chapter-b64', base64enc(line) }
    end, 'Add chapter')
    set('n', 'i', function()
      mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_later' }
    end, 'Nudge later')
    set('n', 'h', function()
      local line = vim.api.nvim_get_current_line()
      mpv_cmd { 'script-message', 'chapters/add-chapter-b64', base64enc(line) }
    end, 'Add chapter')
    set('n', 't', function()
      mpv_cmd { 'no-osd', 'seek', 3, 'exact' }
    end, 'Seek +3s')
    set('n', 'n', function()
      mpv_cmd { 'no-osd', 'seek', -3, 'exact' }
    end, 'Seek -3s')
    set('n', '\\', function()
      mpv_cmd { 'script-message', 'chapter_controls/nudge_chapter_earlier' }
    end, 'Nudge earlier')
    set('n', 'p', function()
      mpv_cmd { 'script-message', 'dynamic_chapter_loop/toggle' }
    end, 'Toggle loop')
    set('n', "'", function()
      mpv_cmd { 'script-message', 'chapters/remove_chapter' }
    end, 'Remove chapter')
    set('n', 'q', function()
      mpv_cmd { 'script-message', 'chapters/write_chapters' }
    end, 'Write chapters')

    vim.api.nvim_create_user_command('MPVSocket', function()
      local socket = get_mpv_socket()
      if socket then
        print('\u{1F3AF} Active MPV socket:', socket)
      else
        print '\u{26A0}\u{FE0F} No MPV socket found for ~/Music or ~/rips'
      end
    end, { desc = 'Show active MPV socket for ~/Music or ~/rips' })
  end,
})
