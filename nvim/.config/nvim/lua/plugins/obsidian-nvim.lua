return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = true,
  event = {
    'BufReadPre ' .. vim.fn.expand '~' .. '/Obsidian/MainVault/*.md',
    'BufNewFile ' .. vim.fn.expand '~' .. '/Obsidian/MainVault/*.md',
  },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    workspaces = { {
      name = 'MainVault',
      path = '~/Obsidian/MainVault',
    } },
    completion = {
      nvim_cmp = false,
      blink = true,
    },
    picker = {
      -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', 'mini.pick' or 'snacks.pick'.
      name = 'snacks.pick',
    },
    templates = {
      folder = 'Templates',
    },
  },
}
