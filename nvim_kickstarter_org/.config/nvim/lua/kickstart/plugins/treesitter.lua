return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    config = function()
      local filetypes = {
        'bash',
        'c',
        'cpp',
        'diff',
        'html',
        'javascript',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'python',
        'tsx',
        'typescript',
        'query',
        'vim',
        'vimdoc',
      }
      require('nvim-treesitter').install(filetypes)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function() vim.treesitter.start() end,
      })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
