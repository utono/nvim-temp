-- File: after/ftplugin/kitty.lua
-- Enforce 2-space indenting for Kitty config files

vim.opt_local.tabstop = 2 -- Tab character is 2 spaces wide
vim.opt_local.softtabstop = 2 -- A soft tab press equals 2 spaces
vim.opt_local.shiftwidth = 2 -- >> and << shift by 2 spaces
vim.opt_local.expandtab = true -- Convert tabs to spaces
