-- NOTE: Plugins can also be configured to run Lua code when they are loaded.
--
-- This is often very useful to both group configuration, as well as handle
-- lazy loading plugins that don't need to be loaded immediately at startup.
--
-- For example, in the following configuration, we use:
--  event = 'VimEnter'
--
-- which loads which-key before all the UI elements are loaded. Events can be
-- normal autocommands events (`:help autocmd-events`).
--
-- Then, because we use the `opts` key (recommended), the configuration runs
-- after the plugin has been loaded as `require(MODULE).setup(opts)`.

return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    ---@module 'which-key'
    ---@type wk.Opts
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },

      -- Document existing key chains
      spec = {
        { '<leader>d', group = '[D]ebug', mode = 'n' },
        { '<leader>w', group = '[W]orkspace', mode = 'n' },
        { '<leader>t', group = '[T]oggle', mode = 'n' },
        { '<leader>T', group = '[T]rouble', mode = 'n' },
        { '<leader>g', group = '[G]it', mode = { 'n', 'v' } },
        { '<leader>u', group = '[U]I Settings', mode = 'n' },
        { '<leader>H', group = '[H]unks', mode = { 'n', 'v' } },
        { '<leader>h', group = '[H]arpoon ', mode = 'n' },
        { '<leader>C', group = '[C]odesnap', mode = 'x' },
        { '<leader>s', group = '[S]earch', icon = { icon = '', color = 'green' } },
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
