-- File: ~/.config/nvim/lua/custom/plugins/zen-colors.lua

return {
  'sainnhe/gruvbox-material',
  name = 'zen-gruvbox-black',
  lazy = true,
  init = function()
    if not vim.g.neovide then
      return
    end

    local function apply_black_background()
      local groups = {
        'Normal',
        'NormalNC',
        'NormalFloat',
        'EndOfBuffer',
        'VertSplit',
        'StatusLine',
        'SignColumn',
        'LineNr',
        'CursorLine',
        'FoldColumn',
        'MsgArea',
        'Pmenu',
        'TelescopeNormal',
        'TelescopeBorder',
        'FloatBorder',
        'LspInfoBorder',
      }

      for _, group in ipairs(groups) do
        local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
        if ok then
          vim.api.nvim_set_hl(0, group, {
            fg = hl.fg or nil,
            bg = '#000000',
            ctermbg = 0,
            default = false,
          })
        end
      end
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'ZenModeEnter',
      desc = 'Apply GruvboxMaterial with pure black background in Zen Mode (Neovide only)',
      callback = function()
        vim.g._zen_prev_colorscheme = vim.g.colors_name or 'default'

        vim.g.gruvbox_material_foreground = 'material'
        vim.g.gruvbox_material_background = 'hard'
        vim.g.gruvbox_material_enable_bold = 1
        vim.g.gruvbox_material_enable_italic = 0
        vim.cmd.colorscheme 'gruvbox-material'

        apply_black_background()
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'ZenModeLeave',
      desc = 'Restore previous colorscheme after Zen Mode',
      callback = function()
        local original = vim.g._zen_prev_colorscheme
        if original and original ~= 'default' then
          pcall(vim.cmd.colorscheme, original)
        end
      end,
    })

    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = 'gruvbox-material',
      callback = function()
        if vim.g.neovide and require('zen-mode.view').is_open() then
          apply_black_background()
        end
      end,
    })

    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        if vim.g.neovide and require('zen-mode.view').is_open() then
          vim.cmd.colorscheme 'gruvbox-material'
          vim.defer_fn(apply_black_background, 150)
        end
      end,
    })
  end,
}
