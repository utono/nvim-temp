-- Disable nvim-cmp for Python files
local cmp_ok, cmp = pcall(require, 'cmp')
if cmp_ok then
  cmp.setup.buffer({ enabled = false })
end

-- Adjust indentation and comments for Python files
vim.opt_local.indentexpr = ""
vim.opt_local.autoindent = true
vim.opt_local.smartindent = true
vim.opt_local.formatoptions:remove("r")
vim.opt_local.formatoptions:remove("o")
vim.opt_local.comments = "" -- Disable automatic comment continuation

-- Set tabstop, shiftwidth, softtabstop, and expandtab for Python files
vim.opt_local.tabstop = 4      -- ts=4: Python typically uses 4 spaces per tab
vim.opt_local.shiftwidth = 4   -- sw=4: Number of spaces used for indentation
vim.opt_local.softtabstop = 4  -- sts=4: Number of spaces for a tab while editing
vim.opt_local.expandtab = true -- et: Convert tabs to spaces

-- Normal mode key mapping to create a Python block comment section heading
vim.api.nvim_buf_set_keymap(0, 'n', '<leader>cs', '', {
  noremap = true,
  silent = true,
  callback = function()
    -- Prompt the user for a section title
    vim.ui.input({ prompt = 'Enter section title: ' }, function(input)
      if input == nil or input == '' then
        return -- If no input, do nothing
      end

      -- Create the block comment section heading
      local comment_heading = {
        '"""',
        "=============================================",
        input,
        "=============================================",
        '"""'
      }

      -- Insert the comment heading above the current line
      local row = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_buf_set_lines(0, row, row, false, comment_heading)
    end)
  end
})
