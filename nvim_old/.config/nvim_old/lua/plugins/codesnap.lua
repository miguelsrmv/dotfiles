return {
  'mistricky/codesnap.nvim',
  tag = 'v2.0.0',
  keys = {
    { '<leader>Cc', '<cmd>CodeSnap<cr>', mode = 'x', desc = 'Save to clipboard' },
    { '<leader>Cs', '<cmd>CodeSnapSave<cr>', mode = 'x', desc = 'Save to directory' },
  },
  opts = {
    save_path = '~/Pictures/CodeSnap',

    snapshot_config = {
      theme = 'bamboo',
      breadcrumbs = {
        enable = true,
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
