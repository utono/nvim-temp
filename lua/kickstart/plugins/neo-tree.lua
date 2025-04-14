-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    -- { '\\', ':Neotree reveal_force_cwd<CR>', desc = 'NeoTree reveal with forced cwd', silent = true },
    -- { '+', ':Neotree source=buffers position=right toggle<CR>', desc = 'Toggle NeoTree Buffers Right', silent = true },
    -- { 'q', ':Neotree close<CR>', desc = 'Close NeoTree window', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          -- ['\\'] = 'close_window', -- Optional: Map comma to close Neo-tree windows within the plugin
        },
      },
    },
  },
}

-- nnoremap / :Neotree toggle current reveal_force_cwd<cr>
-- nnoremap | :Neotree reveal<cr>
-- nnoremap gd :Neotree float reveal_file=<cfile> reveal_force_cwd<cr>
-- nnoremap <leader>b :Neotree toggle show buffers right<cr>
-- nnoremap <leader>s :Neotree float git_status<cr>
