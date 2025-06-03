return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      },

      auto_install = true,

      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },

      indent = {
        enable = true,
        disable = { 'ruby' },
      },

      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump to the textobject
          keymaps = {
            ['af'] = '@function.outer', -- around function
            ['if'] = '@function.inner', -- inner function
            ['ac'] = '@class.outer', -- around class
            ['ic'] = '@class.inner', -- inner class
          },
        },
      },
    },
  },
}
