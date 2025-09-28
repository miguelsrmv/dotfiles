return {
  { 'EdenEast/nightfox.nvim', opts = { transparent = true } },
  { 'folke/tokyonight.nvim' },
  { 'catppuccin/nvim', name = 'catppuccin' },
  { 'gbprod/nord.nvim' },
  {
    'neanias/everforest-nvim',
    config = function()
      require('everforest').setup {}
    end,
  },
  { 'ellisonleao/gruvbox.nvim' },
  { 'rebelot/kanagawa.nvim' },
  { 'rose-pine/neovim', name = 'rose-pine' },
  { 'olimorris/onedarkpro.nvim' },
  { 'mofiqul/dracula.nvim' },
  { 'tahayvr/matteblack.nvim' },
  {
    'ribru17/bamboo.nvim',
    config = function()
      require('bamboo').setup {}
      require('bamboo').load()
    end,
  },
  {
    'gthelding/monokai-pro.nvim',
    opts = {
      filter = 'ristretto',
      override = function()
        return {
          NonText = { fg = '#948a8b' },
          MiniIconsGrey = { fg = '#948a8b' },
          MiniIconsRed = { fg = '#fd6883' },
          MiniIconsBlue = { fg = '#85dacc' },
          MiniIconsGreen = { fg = '#adda78' },
          MiniIconsYellow = { fg = '#f9cc6c' },
          MiniIconsOrange = { fg = '#f38d70' },
          MiniIconsPurple = { fg = '#a8a9eb' },
          MiniIconsAzure = { fg = '#a8a9eb' },
          MiniIconsCyan = { fg = '#85dacc' }, -- consistency
        }
      end,
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
