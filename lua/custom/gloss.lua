local M = {}

M.gloss_selection = function()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  -- Handle edge case: empty or invalid selection
  if #lines == 0 then
    vim.notify('No text selected', vim.log.levels.WARN)
    return
  end

  -- Safely adjust the start and end columns
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
  else
    lines[1] = string.sub(lines[1], start_pos[3], -1)
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  end

  local text = table.concat(lines, '\n')

  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, 'w')
  f:write(text)
  f:close()

  local output = vim.fn.systemlist('python3 ~/.config/nvim/python/gloss_text.py < ' .. tmpfile)
  vim.fn.delete(tmpfile)

  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    border = 'rounded',
    style = 'minimal',
  })

  vim.bo[buf].filetype = 'markdown'

  -- Close window with q or <Esc>
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(0, true)
  end, { buffer = buf, nowait = true, silent = true })

  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(0, true)
  end, { buffer = buf, nowait = true, silent = true })
end

return M
