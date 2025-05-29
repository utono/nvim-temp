local M = {}

-- Configurable horizontal padding
M.config = {
  horizontal_padding = 2,
}

M.gloss_selection = function()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if #lines == 0 then
    vim.notify('No text selected', vim.log.levels.WARN)
    return
  end

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

  local gloss_output = vim.fn.systemlist('python3 ~/.config/nvim/python/gloss_text.py < ' .. tmpfile)
  vim.fn.delete(tmpfile)

  -- Combine original block + blank line + gloss
  local original_block = vim.tbl_map(function(line)
    return '> ' .. line
  end, lines)

  local combined_output = vim.list_extend(vim.list_extend(original_block, { '' }), gloss_output)

  -- Apply horizontal padding
  local pad = string.rep(' ', M.config.horizontal_padding)
  local padded = vim.tbl_map(function(line)
    return pad .. line .. pad
  end, combined_output)

  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    border = 'rounded',
    style = 'minimal',
  })

  vim.bo[buf].filetype = 'markdown'

  -- Save current guicursor value
  local original_guicursor = vim.o.guicursor

  -- Set a solid block cursor that doesn't blink (or hide it entirely)
  vim.o.guicursor = 'n-v-c:block' -- solid block, no blink
  -- vim.o.guicursor = 'a:Cursor/lCursor' -- fully hidden
  -- vim.o.guicursor = 'n-v-c:ver1'       -- minimal dot-like vertical bar

  -- When the gloss window closes, restore the previous guicursor setting
  vim.keymap.set('n', 'q', function()
    vim.o.guicursor = original_guicursor
    vim.api.nvim_win_close(0, true)
  end, { buffer = buf, nowait = true, silent = true })

  vim.keymap.set('n', '<Esc>', function()
    vim.o.guicursor = original_guicursor
    vim.api.nvim_win_close(0, true)
  end, { buffer = buf, nowait = true, silent = true })
end

return M
