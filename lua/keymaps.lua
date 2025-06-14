-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.keymap.set('n', ';', ':', { desc = 'Enter command mode' })
vim.keymap.set('n', ':', ';', { desc = 'Repeat last f, t, F, or T movement' })
vim.keymap.set('n', '-', '<C-^>', { desc = 'Switch to last visited buffer' })

-- Remap Shift+U to undo
vim.keymap.set('n', 'U', 'u', { desc = 'Undo' })

-- Disable the default undo key (u)
vim.keymap.set('n', 'u', '<Nop>', { desc = 'Disable undo key' })

vim.keymap.set('n', '<leader>dt', ':diffthis<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>do', ':diffoff<CR>', { noremap = true, silent = true })
-- Change working directory to the directory of the current file
vim.keymap.set('n', '<leader>cd', function()
  vim.cmd 'tcd %:h'
  print('Changed directory to: ' .. vim.fn.getcwd())
end, { desc = 'Change directory to file location and echo new cwd' })

-- Save session with user prompt
vim.keymap.set('n', '<leader>ms', function()
  local session_name = vim.fn.input 'Save session as: '
  if session_name ~= '' then
    MiniSessions.write(session_name)
  else
    print 'Session name cannot be empty!'
  end
end, { noremap = true, silent = true })

-- Load session with user prompt
vim.keymap.set('n', '<leader>ml', function()
  local session_name = vim.fn.input 'Load session: '
  if session_name ~= '' then
    MiniSessions.read(session_name)
  else
    print 'Session name cannot be empty!'
  end
end, { noremap = true, silent = true })

-- Delete session with user prompt
vim.keymap.set('n', '<leader>md', function()
  local session_name = vim.fn.input 'Delete session: '
  if session_name ~= '' then
    MiniSessions.delete(session_name)
  else
    print 'Session name cannot be empty!'
  end
end, { noremap = true, silent = true })

vim.keymap.set('i', 'ht', '<Esc>', { desc = 'Exit insert mode' })

vim.keymap.set('v', 'o', [[:<C-u>lua require('custom.gloss').gloss_selection()<CR>]], {
  desc = 'Gloss selected Shakespeare text (Arden style)',
  silent = true,
})

vim.keymap.set('n', '<leader>nn', '<cmd>ZenMode<CR>', { desc = 'Toggle Zen Mode' })

vim.api.nvim_create_user_command('ReloadConfig', function()
  for name, _ in pairs(package.loaded) do
    if name:match '^custom' or name:match '^kickstart' then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)

  -- Rerun lualine setup manually using the same opts function
  local lualine_spec = require 'custom.lualine' -- adjust path if not in custom/plugins
  require('lualine').setup(lualine_spec.opts())

  vim.notify('Neovim config reloaded!', vim.log.levels.INFO)
end, {})

vim.keymap.set('n', '<leader>vr', '<cmd>ReloadConfig<CR>', { desc = '[V]im [R]eload config' })

vim.keymap.set('n', '<leader>ct', function()
  require('custom.colorscheme-selector').pick()
end, { desc = '[C]olorscheme [T]oggle picker' })

vim.keymap.set('n', '<leader>cr', function()
  require('custom.colorscheme-selector').load_last()
end, { desc = '[C]olorscheme [R]eload last' })

vim.keymap.set('n', '<leader>cf', function()
  -- vim.cmd.colorscheme 'gruvbox-material'
  vim.cmd.colorscheme 'rose-pine'
  -- vim.notify('Reset to default colorscheme: gruvbox-material', vim.log.levels.INFO)
  vim.notify('Reset to default colorscheme: rose-pine', vim.log.levels.INFO)
end, { desc = '[C]olorscheme [D]efault reset' })

vim.keymap.set('n', '<leader>cc', function()
  require('custom.colorscheme-selector').cycle()
end, { desc = '[C]olorscheme cycle →' })

vim.keymap.set('n', '<leader>cb', function()
  require('custom.colorscheme-selector').cycle_back()
end, { desc = '[C]olorscheme cycle ←' })

-- Toggle Twilight dimming
vim.keymap.set('n', '<leader>tt', '<cmd>Twilight<CR>', { desc = '[T]oggle [T]wilight' })

-- vim: ts=2 sts=2 sw=2 et
