-- File: lua/custom/plugins/zen-mode.lua

return {
  'folke/zen-mode.nvim',
  cmd = 'ZenMode',
  opts = {
    window = {
      -- backdrop = 0.75,
      -- backdrop = 0.95,
      backdrop = 1,
      -- width = 90,
      width = 0.5,
      height = 0.9,
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
        laststatus = 0, -- turn off the statusline is zen mode
      },
      gitsigns = { enabled = false },
      tmux = { enabled = false },
      kitty = {
        enabled = true,
        font = '+2',
      },
    },

    on_open = function()
      local function set_kitty_font(size)
        if not vim.g.neovide then
          vim.fn.jobstart({ 'kitty', '@', 'set-font-size', size }, { detach = true })
        end
      end

      -- toggle lualine to minimal (no statusline)
      require('custom.lualine-toggle').toggle()

      vim.b._zen_scrolloff = vim.o.scrolloff
      vim.o.scrolloff = math.floor((vim.o.lines - vim.o.cmdheight - 2) / 2)

      local file = vim.api.nvim_buf_get_name(0)
      local filetype = vim.bo.filetype

      if not vim.g.neovide and not vim.g._zen_kitty_default_font_set then
        vim.g._zen_kitty_default_font_set = true
        vim.system({ 'kitty', '@', 'get-font-size' }, { text = true }, function(obj)
          if obj.code == 0 and obj.stdout then
            vim.schedule(function()
              vim.g._zen_kitty_font_before = tonumber(vim.trim(obj.stdout)) or 0
            end)
          end
        end)
      end

      if file:find(vim.fn.expand '~/utono/literature/', 1, true) == 1 then
        set_kitty_font '+4'
        vim.opt_local.scroll = 1
        vim.opt.guicursor = { 'n-v-c:block' }
        vim.opt_local.cursorline = false
        vim.diagnostic.disable(0)
        vim.cmd 'hi! link GitSignsAdd Normal'
        vim.cmd 'hi! link GitSignsChange Normal'
        vim.cmd 'hi! link GitSignsDelete Normal'
        if vim.g.neovide then
          vim.g.neovide_scroll_animation_length = 0.2
          vim.g.neovide_cursor_animation_length = 0
          vim.g.neovide_hide_mouse_when_typing = true
          vim.g.neovide_scale_factor = 1.2
        end
      else
        set_kitty_font '+2'
      end
    end,

    on_close = function()
      -- toggle lualine back to full (statusline enabled)
      require('custom.lualine-toggle').toggle()

      if vim.b._zen_scrolloff then
        vim.o.scrolloff = vim.b._zen_scrolloff
        vim.b._zen_scrolloff = nil
      end

      if vim.g.neovide then
        vim.g.neovide_scale_factor = 1.0
      else
        local font = vim.g._zen_kitty_font_before
        local restore = font and tostring(font) or '0'
        vim.fn.jobstart({ 'kitty', '@', 'set-font-size', restore }, { detach = true })
      end
    end,
  },

  init = function()
    vim.api.nvim_create_autocmd('UIEnter', {
      once = true,
      callback = function()
        vim.schedule(function()
          if not vim.g.neovide then
            return
          end
          local bufname = vim.api.nvim_buf_get_name(0)
          if bufname:find(vim.fn.expand '~/utono/literature/', 1, true) == 1 then
            vim.cmd 'ZenMode'
          end
        end)
      end,
    })

    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        if not vim.g.neovide then
          return
        end
        local ok, view = pcall(require, 'zen-mode.view')
        if ok and view.is_open() then
          vim.fn.jobstart({ 'kitty', '@', 'set-font-size', '0' }, { detach = true })
        end
      end,
    })
  end,
}
