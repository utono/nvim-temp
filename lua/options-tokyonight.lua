-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.opt.hidden = false

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "lua",
--   callback = function()
--     -- Disable nvim-cmp for Lua files
--     local cmp = require('cmp')
--     cmp.setup.buffer({ enabled = false })
--
--     -- Adjust indentation and comments for Lua files
--     vim.opt_local.indentexpr = ""
--     vim.opt_local.autoindent = true
--     vim.opt_local.smartindent = true
--     vim.opt_local.formatoptions:remove("r")
--     vim.opt_local.formatoptions:remove("o")
--     vim.opt_local.comments = "" -- Disable automatic comment continuation
--
--     -- Set tabstop, shiftwidth, softtabstop, and expandtab for Lua files
--     vim.opt_local.tabstop = 2      -- ts=2: Number of spaces a tab counts for
--     vim.opt_local.shiftwidth = 2   -- sw=2: Number of spaces used for indentation
--     vim.opt_local.softtabstop = 2  -- sts=2: Number of spaces for a tab while editing
--     vim.opt_local.expandtab = true -- et: Convert tabs to spaces
--   end
-- })

-- Customize highlights for tokyonight-night after colorscheme loads
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    -- Active window: transparent
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })

    -- Inactive windows: dimmed background
    -- vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#16161e' })
    vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#1f2335' }) -- gentle dim
    -- vim.api.nvim_set_hl(0, 'NormalNC', { bg = '#1a1b26' }) -- same as Normal (almost no dim)

    -- UI elements
    vim.api.nvim_set_hl(0, 'LineNr', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'none', underline = true })
    vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'none', fg = '#565f89' })

    -- Neo-tree
    vim.api.nvim_set_hl(0, 'NeoTreeNormal', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { bg = 'none' })

    -- Enhanced diff colors
    vim.api.nvim_set_hl(0, 'DiffAdd', { fg = '#9ece6a', bg = '#203030', bold = true })
    vim.api.nvim_set_hl(0, 'DiffDelete', { fg = '#f7768e', bg = '#3b2f33', bold = true })
    vim.api.nvim_set_hl(0, 'DiffChange', { fg = '#7aa2f7', bg = '#1f2d40' })
    vim.api.nvim_set_hl(0, 'DiffText', { fg = '#c0caf5', bg = '#394b70', bold = true })

    -- Tabline clarity
    vim.api.nvim_set_hl(0, 'TabLine', { fg = '#7aa2f7', bg = '#1a1b26' })
    vim.api.nvim_set_hl(0, 'TabLineSel', { fg = '#1a1b26', bg = '#7aa2f7', bold = true })
    vim.api.nvim_set_hl(0, 'TabLineFill', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'TabLineModified', { fg = '#e0af68', bold = true })
  end,
})

vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,resize,globals'
-- vim: ts=2 sts=2 sw=2 et
