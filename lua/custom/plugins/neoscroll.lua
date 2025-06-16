-- File: ~/.config/nvim/lua/custom/plugins/neoscroll.lua

return {
  'karb94/neoscroll.nvim',
  event = 'VeryLazy',
  opts = {
    -- Hide the cursor while scrolling
    hide_cursor = true,

    -- Stop at the end of file
    stop_eof = true,

    -- Respect scrolloff setting
    respect_scrolloff = true,

    -- Allow scrolling when the cursor reaches the window edge
    cursor_scrolls_alone = true,

    -- Use default easing functions for smooth animation
    easing_function = nil, -- "sine", "circular", "quadratic", etc.

    -- Mappings are enabled by default
    -- You can set this to false if you want to define your own
    mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', 'zt', 'zz', 'zb' },
  },
}
