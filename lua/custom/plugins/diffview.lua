-- Persistent diff view interface for Git history and changes
-- https://github.com/sindrets/diffview.nvim

return {
  'sindrets/diffview.nvim',
  cmd = {
    'DiffviewOpen',
    'DiffviewClose',
    'DiffviewToggleFiles',
    'DiffviewFocusFiles',
    'DiffviewFileHistory',
  },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = '[G]it [D]iff view' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = '[G]it file [H]istory' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<CR>', desc = '[G]it [H]istory (project)' },
    { '<leader>gq', '<cmd>DiffviewClose<CR>', desc = '[G]it diff [Q]uit' },
  },
  opts = {
    use_icons = vim.g.have_nerd_font,
    enhanced_diff_hl = true,
    view = {
      default = {
        layout = 'diff2_horizontal',
      },
    },
    file_panel = {
      listing_style = 'tree',
      win_config = {
        position = 'left',
        width = 35,
      },
    },
  },
}
