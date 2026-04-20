-- [[ Configure and install plugins ]]
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
require('lazy').setup {
  -- Auto-import all plugins from the plugin directory
  { import = 'plugins' },
}

-- vim: ts=2 sts=2 sw=2 et
