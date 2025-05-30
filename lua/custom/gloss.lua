local M = {}

-- Configurable options
M.config = {
  left_indent = 2,
  right_margin = 2,
  max_width = 120,
  log_filename = 'gloss.md',
  log_dir = vim.fn.expand '~/utono/literature',
  display_mode = 'float', -- options: 'float', 'split', 'vsplit'
}

local function wrap_line(line, max_width, prefix)
  local wrapped = {}
  local raw = prefix .. line
  local available = max_width

  while #raw > available do
    local i = available
    while i > #prefix and raw:sub(i, i) ~= ' ' do
      i = i - 1
    end
    if i == #prefix then
      i = available
    end
    wrapped[#wrapped + 1] = raw:sub(1, i):gsub('%s+$', '')
    raw = prefix .. raw:sub(i + 1):gsub('^%s+', '')
  end

  wrapped[#wrapped + 1] = raw
  return wrapped
end

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
  -- Prompt user for optional tag (e.g., "RJ II.2")
  local tag = vim.fn.expand '%:t' -- e.g., "romeo.txt"
  local source_file = vim.fn.expand '%:p' -- full path to the file

  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, 'w')
  f:write(text)
  f:close()

  local gloss_output = vim.fn.systemlist('python3 ~/.config/nvim/python/gloss_text.py < ' .. tmpfile)
  -- Log the gloss output to a file
  local log_path = M.config.log_dir .. '/' .. M.config.log_filename
  vim.fn.mkdir(M.config.log_dir, 'p') -- ensure directory exists
  local log_file = io.open(log_path, 'a')

  if log_file then
    log_file:write('\n' .. string.rep('-', 80) .. '\n')
    log_file:write('Gloss created on: ' .. os.date '%Y-%m-%d %H:%M:%S' .. '\n')
    log_file:write('Tag: ' .. tag .. '\n')
    log_file:write('Source file: ' .. source_file .. '\n\n')
    for _, line in ipairs(lines) do
      for _, wrapped in ipairs(wrap_line(line, M.config.max_width, '> ')) do
        log_file:write(wrapped .. '\n')
      end
    end
    log_file:write '\n'
    for _, line in ipairs(gloss_output) do
      for _, wrapped in ipairs(wrap_line(line, M.config.max_width, '')) do
        log_file:write(wrapped .. '\n')
      end
    end
    log_file:close()
  else
    vim.notify('Could not write to ' .. log_path, vim.log.levels.ERROR)
  end
  vim.fn.delete(tmpfile)

  -- Format quoted lines only
  local left_pad = string.rep(' ', M.config.left_indent)
  local right_pad = string.rep(' ', M.config.right_margin)

  local quoted = {}
  for _, line in ipairs(lines) do
    for _, wrapped in ipairs(wrap_line(line, M.config.max_width, '> ')) do
      table.insert(quoted, left_pad .. wrapped .. right_pad)
    end
  end

  -- Add a blank line after quote block
  table.insert(quoted, '')

  -- Append gloss block with no extra padding
  for _, line in ipairs(gloss_output) do
    table.insert(quoted, line)
  end

  local width = math.min(M.config.max_width, vim.o.columns - M.config.right_margin)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, quoted)

  local win
  if M.config.display_mode == 'float' then
    win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      row = row,
      col = col,
      border = 'rounded',
      style = 'minimal',
    })
  else
    if M.config.display_mode == 'split' then
      vim.cmd 'split'
    elseif M.config.display_mode == 'vsplit' then
      vim.cmd 'vsplit'
    end
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
  end

  vim.bo[buf].filetype = 'markdown'

  -- Word wrap enabled with no hanging indent (just quote prefix)
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].breakindent = false
  vim.wo[win].showbreak = ''

  -- Close keybindings
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(0, true)
  end, { buffer = buf, nowait = true, silent = true })

  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(0, true)
  end, { buffer = buf, nowait = true, silent = true })
end

return M
