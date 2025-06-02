-- File: lua/custom/plugins/zen-mode.lua

return {
  'folke/zen-mode.nvim',
  cmd = 'ZenMode',
  opts = {
    window = {
      width = 90,
      options = {
        signcolumn = 'no',
        number = false,
        relativenumber = false,
        cursorline = false,
        foldcolumn = '0',
        list = false,
        wrap = false,
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
        font = '+2', -- default (writing), overridden below if needed
      },
    },
    on_open = function()
      local zen_height = vim.o.lines - vim.o.cmdheight - 2
      vim.b._zen_prev_scrolloff = vim.o.scrolloff
      vim.o.scrolloff = math.floor(zen_height / 2)

      -- Determine font size and scrolling behavior based on path or filetype
      local file = vim.api.nvim_buf_get_name(0)
      local filetype = vim.bo.filetype

      if file:find(vim.fn.expand '~/utono/literature/', 1, true) == 1 then
        vim.fn.jobstart { 'kitty', '@', 'set-font-size', '+4' }
        vim.opt_local.scroll = 1
        vim.opt.guicursor = { 'n-v-c:block' }
        vim.opt_local.cursorline = false
        vim.diagnostic.disable(0)
        vim.cmd 'hi! link GitSignsAdd Normal'
        vim.cmd 'hi! link GitSignsChange Normal'
        vim.cmd 'hi! link GitSignsDelete Normal'

        -- Enable smooth scroll in Neovide if applicable
        if vim.g.neovide then
          vim.g.neovide_scroll_animation_length = 0.2
          vim.g.neovide_cursor_animation_length = 0
          vim.g.neovide_hide_mouse_when_typing = true
        end
      elseif filetype == 'markdown' or filetype == 'rst' then
        vim.fn.jobstart { 'kitty', '@', 'set-font-size', '+2' }
      else
        vim.fn.jobstart { 'kitty', '@', 'set-font-size', '+2' }
      end
    end,
    on_close = function()
      if vim.b._zen_prev_scrolloff then
        vim.o.scrolloff = vim.b._zen_prev_scrolloff
        vim.b._zen_prev_scrolloff = nil
      end
      -- Reset font size to default
      vim.fn.jobstart { 'kitty', '@', 'set-font-size', '0' }
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
