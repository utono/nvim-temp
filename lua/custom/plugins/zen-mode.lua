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
        if not vim.g.neovide then
          vim.fn.jobstart { 'kitty', '@', 'set-font-size', '+4' }
        end
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
          vim.g.neovide_scale_factor = 1.2
        end
      elseif filetype == 'markdown' or filetype == 'rst' then
        if not vim.g.neovide then
          vim.fn.jobstart { 'kitty', '@', 'set-font-size', '+2' }
        end
      else
        vim.fn.jobstart { 'kitty', '@', 'set-font-size', '+2' }
      end
    end,
    on_close = function()
      if vim.b._zen_prev_scrolloff then
        vim.o.scrolloff = vim.b._zen_prev_scrolloff
        vim.b._zen_prev_scrolloff = nil
      end
      if not vim.g.neovide then
        vim.fn.jobstart { 'kitty', '@', 'set-font-size', '0' }
      end
      if vim.g.neovide then
        vim.g.neovide_scale_factor = 1.0
      end
    end,
  },
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'markdown', 'text' },
      callback = function()
        vim.schedule(function()
          if not vim.g.neovide then
            return
          end
          require('zen-mode').toggle()
        end)
      end,
    })

    -- ⬇️ Auto-scroll control: toggle, faster, slower
    local scroll_timer = nil
    local scrolling = false
    local scroll_interval = 1000 -- default: 1 second

    vim.keymap.set('n', '<Down>', function()
      if not vim.g.neovide then
        print 'Auto-scroll only works in Neovide'
        return
      end

      if scrolling then
        scroll_timer:stop()
        scroll_timer:close()
        scroll_timer = nil
        scrolling = false
        print 'Auto-scroll stopped'
      else
        scroll_timer = vim.loop.new_timer()
        scroll_timer:start(
          0,
          scroll_interval,
          vim.schedule_wrap(function()
            if vim.fn.line '.' < vim.fn.line '$' then
              vim.cmd 'normal! j'
            else
              scroll_timer:stop()
              scroll_timer:close()
              scroll_timer = nil
              scrolling = false
              print 'Reached end of file — auto-scroll stopped'
            end
          end)
        )
        scrolling = true
        print('Auto-scroll started (interval: ' .. scroll_interval .. 'ms)')
      end
    end, { desc = 'Toggle auto-scroll in Neovide' })

    vim.keymap.set('n', '<Right>', function()
      scroll_interval = math.max(100, scroll_interval - 200)
      print('Scroll faster (interval: ' .. scroll_interval .. 'ms)')
    end, { desc = 'Scroll Faster' })

    vim.keymap.set('n', '<Left>', function()
      scroll_interval = scroll_interval + 200
      print('Scroll slower (interval: ' .. scroll_interval .. 'ms)')
    end, { desc = 'Scroll Slower' })
  end,
}
