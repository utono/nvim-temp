-- File: lua/kickstart/plugins/telescope.lua

-- NOTE: Plugins can specify dependencies.
--
-- The dependencies are proper plugin specifications as well - anything
-- you do for a plugin at the top level, you can do for a dependency.
--
-- Use the `dependencies` key to specify the dependencies of a particular plugin

return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      local actions = require 'telescope.actions'

      vim.keymap.set('n', '<leader>sp', builtin.help_tags, { desc = '[S]earch Hel[p]' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })

      -- Zen-safe grep: send results to quickfix but don't open it
      vim.keymap.set('n', '<leader>sg', function()
        builtin.live_grep {
          attach_mappings = function(_, map)
            map('i', '<C-q>', function(prompt_bufnr)
              actions.smart_send_to_qflist(prompt_bufnr)
              vim.schedule(function()
                vim.cmd 'cclose'
              end)
            end)
            map('n', '<C-q>', function(prompt_bufnr)
              actions.smart_send_to_qflist(prompt_bufnr)
              vim.schedule(function()
                vim.cmd 'cclose'
              end)
            end)
            return true
          end,
        }
      end, { desc = '[S]earch by [G]rep (Zen safe)' })

      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })

      vim.keymap.set('n', '<leader>sh', function()
        builtin.live_grep {
          cwd = '~/utono/md-arch',
          glob_pattern = { '*.md', '*.rst' },
          prompt_title = 'Search Markdown and ReStructuredText Files',
          layout_config = {
            width = 0.95,
            height = 0.95,
            preview_width = 0.6,
          },
        }
      end, { desc = 'Search Markdown and RST files' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
