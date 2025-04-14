-- Disable nvim-cmp for Lua files
local cmp_ok, cmp = pcall(require, 'cmp')
if cmp_ok then
  cmp.setup.buffer({ enabled = false })
end

-- Adjust indentation and comments for Lua files
vim.opt_local.indentexpr = ""
vim.opt_local.autoindent = true
vim.opt_local.smartindent = true
vim.opt_local.formatoptions:remove("r")
vim.opt_local.formatoptions:remove("o")
vim.opt_local.comments = "" -- Disable automatic comment continuation

-- Set tabstop, shiftwidth, softtabstop, and expandtab for Lua files
vim.opt_local.tabstop = 2      -- ts=2: Number of spaces a tab counts for
vim.opt_local.shiftwidth = 2   -- sw=2: Number of spaces used for indentation
vim.opt_local.softtabstop = 2  -- sts=2: Number of spaces for a tab while editing
vim.opt_local.expandtab = true -- et: Convert tabs to spaces

-- Normal mode key mapping to create a Lua block comment section heading
vim.api.nvim_buf_set_keymap(0, 'n', '<leader>cs', '', {
  noremap = true,
  silent = true,
  callback = function()
    -- Prompt the user for a section title
    vim.ui.input({ prompt = 'Enter section title: ' }, function(input)
      if input == nil or input == '' then
        return -- If no input, do nothing
      end

      -- Create the rest of the block comment (after the initial --[[)
      local comment_body = {
        "=============================================",
        input,
        "=============================================",
        "]]"
      }

      -- Get the current cursor position (row and column)
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))

      -- Fetch the current line
      local current_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]

      -- Replace the part of the line starting from the cursor position with --[[
      local new_line = current_line:sub(1, col) .. "--[["

      -- Set the updated current line with --[[
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })

      -- Insert the remaining lines of the block comment starting from the next line
      vim.api.nvim_buf_set_lines(0, row, row, false, comment_body)

      -- Insert a new empty line after the ]]
      vim.api.nvim_buf_set_lines(0, row + #comment_body, row + #comment_body, false, { "" })

      -- Move the cursor to the new empty line after the ]]
      vim.api.nvim_win_set_cursor(0, { row + #comment_body + 1, 0 })
    end)
  end
})
