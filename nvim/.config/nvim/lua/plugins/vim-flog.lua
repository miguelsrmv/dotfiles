return {
  'rbong/vim-flog',
  lazy = false,
  cmd = { 'Flog', 'Flogsplit', 'Floggit' },
  dependencies = {
    'tpope/vim-fugitive',
  },
  config = function()
    vim.keymap.set('n', '<leader>gF', function()
      vim.cmd 'Flog' -- This ensures the command runs even if the plugin was not manually triggered
    end, { silent = true, desc = 'Open Flog (Git Graph)' })
  end,
}
-- vim: ts=2 sts=2 sw=2 et
