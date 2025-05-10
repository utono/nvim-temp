-- lua/custom/plugins/mpv_chapter.lua

return {
  dir = vim.fn.stdpath 'config' .. '/lua/custom/plugins/mpv_chapter',
  name = 'mpv_chapter',
  lazy = false,
  config = function()
    local mpv_socket = '/tmp/mpvsocket'

    local function mpv_running()
      return vim.fn.filereadable(mpv_socket) == 1 or vim.loop.fs_stat(mpv_socket)
    end

    local function trim_and_truncate(text)
      text = text:gsub('^%s+', ''):gsub('%s+$', '')
      if #text > 120 then
        text = text:sub(1, 120)
      end
      return text
    end

    local function send_to_mpv(title)
      local json = string.format([[echo '{ "command": ["script-message", "add-chapter", "%s"] }' | socat - %s]], title, mpv_socket)
      vim.fn.jobstart({ 'sh', '-c', json }, { detach = true })
    end

    local function add_chapter()
      local mode = vim.api.nvim_get_mode().mode
      local text = ''

      if mode == 'v' or mode == 'V' or mode == '\22' then
        vim.cmd 'normal! "vy'
        text = vim.fn.getreg 'v'
      else
        vim.cmd 'normal! yy'
        text = vim.fn.getreg '"'
      end

      text = trim_and_truncate(text)

      if not mpv_running() then
        vim.notify('MPV is not running or socket missing', vim.log.levels.ERROR, { title = 'mpv_chapter' })
        return
      end

      if text == '' then
        vim.notify('No text captured', vim.log.levels.WARN, { title = 'mpv_chapter' })
        return
      end

      send_to_mpv(text:gsub("'", "\\'"))
      vim.notify('Sent chapter to MPV: ' .. text, vim.log.levels.INFO, { title = 'mpv_chapter' })
    end

    -- Set the keybinding (- key in normal and visual modes)
    vim.keymap.set({ 'n', 'v' }, '-', add_chapter, { desc = '[MPV] Add chapter from line or selection' })
  end,
}
