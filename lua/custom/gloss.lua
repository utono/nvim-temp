local M = {}

-- Configurable options
M.config = {
  left_indent = 2,
  right_margin = 2,
  max_width = 120,
  log_filename = 'gloss.md',
  log_dir = vim.fn.expand '~/utono/literature',
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
  local was_zen = require('zen-mode.view').is_open()
  if was_zen then
    require('zen-mode').close()
  end

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
  local tag = vim.fn.expand '%:t'
  local source_file = vim.fn.expand '%:p'

  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, 'w')
  f:write(text)
  f:close()

  local gloss_output = vim.fn.systemlist('python3 ~/.config/nvim/python/gloss_text.py < ' .. tmpfile)
  local log_path = M.config.log_dir .. '/' .. M.config.log_filename
  vim.fn.mkdir(M.config.log_dir, 'p')
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

  local left_pad = string.rep(' ', M.config.left_indent)
  local right_pad = string.rep(' ', M.config.right_margin)

  local quoted = {}
  for _, line in ipairs(lines) do
    for _, wrapped in ipairs(wrap_line(line, M.config.max_width, '> ')) do
      table.insert(quoted, left_pad .. wrapped .. right_pad)
    end
  end
  table.insert(quoted, '')
  for _, line in ipairs(gloss_output) do
    table.insert(quoted, line)
  end

  local current_buf = vim.api.nvim_get_current_buf()

  vim.cmd 'enew'
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, quoted)
  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false

  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.breakindent = false
  vim.wo.showbreak = ''

  require('zen-mode').open()

  vim.keymap.set('n', 'q', function()
    vim.cmd 'bdelete'
    vim.api.nvim_set_current_buf(current_buf)
    require('zen-mode').open()
  end, { buffer = buf, nowait = true, silent = true })

  vim.keymap.set('n', '<Esc>', function()
    vim.cmd 'bdelete'
    vim.api.nvim_set_current_buf(current_buf)
    require('zen-mode').open()
  end, { buffer = buf, nowait = true, silent = true })
end

return M
