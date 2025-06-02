-- File: lua/custom/plugins/zen-mode.lua

return {
  'folke/zen-mode.nvim',
  cmd = 'ZenMode',
  opts = {
    window = {
      width = 90,
      -- explicitly allow full height
      options = {
        signcolumn = 'no',
        number = false,
        relativenumber = false,
        cursorline = false,
        foldcolumn = '0',
        list = false,
      },
    },
    plugins = {
      options = {
        enabled = true,
        ruler = false,
        showcmd = false,
      },
      gitsigns = { enabled = false },
      tmux = { enabled = false },
      kitty = {
        enabled = true,
        font = '+4', -- use '+2' for prose writing
      },
    },
    on_open = function()
      local zen_height = vim.o.lines - vim.o.cmdheight - 2
      vim.b._zen_prev_scrolloff = vim.o.scrolloff
      vim.o.scrolloff = math.floor(zen_height / 2)
    end,
    on_close = function()
      if vim.b._zen_prev_scrolloff then
        vim.o.scrolloff = vim.b._zen_prev_scrolloff
        vim.b._zen_prev_scrolloff = nil
      end
    end,
  },
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'markdown', 'text' },
      callback = function()
        vim.schedule(function()
          require('zen-mode').toggle()
        end)
      end,
    })
  end,
}
