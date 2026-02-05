return {
  'folke/trouble.nvim',
  opts = {}, -- for default options, refer to the configuration section for custom setup.
  cmd = 'Trouble',
  keys = {
    {
      '<leader>Tx',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnostics',
    },
    {
      '<leader>TX',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Buffer Diagnostics',
    },
    {
      '<leader>Ts',
      '<cmd>Trouble symbols toggle focus=false<cr>',
      desc = 'Symbols',
    },
    {
      '<leader>Tl',
      '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
      desc = 'LSP Definitions / references / ...',
    },
    {
      '<leader>TL',
      '<cmd>Trouble loclist toggle<cr>',
      desc = 'Location List',
    },
    {
      '<leader>TQ',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Quickfix List',
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
