-- File: theme_switcher.lua

-- 1. Define the path to the file your shell script modifies.
--    Using vim.fn.expand to handle '~' correctly.
local theme_state_file = vim.fn.expand '~/.config/nvim/lua/custom/theme_state.lua'

-- 2. Create the function that will apply the theme.
--

local function apply_theme()
  package.loaded['custom.theme_state'] = nil
  local ok, state = pcall(require, 'custom.theme_state')
  if not ok then
    vim.notify('Error loading theme state: ' .. tostring(state), vim.log.levels.ERROR)
    return
  end
  if state and state.theme then
    local theme_name = vim.trim(state.theme)
    local colorscheme_ok, _ = pcall(vim.cmd.colorscheme, theme_name)
    if not colorscheme_ok then
      vim.notify("Colorscheme '" .. theme_name .. "' not found.", vim.log.levels.WARN)
    end
  end
end

-- 3. Create and start the file system watcher.
--    vim.loop is Neovim's interface to the libuv event loop.
local fs_watcher = vim.loop.new_fs_poll()

-- The callback function is executed when a change is detected.
-- It receives (err, stat, prev_stat). We don't need them, but they're there.
fs_watcher:start(theme_state_file, 1000, function() -- Check every 1000ms (can be lower)
  -- When the file changes, call our function to apply the new theme.
  vim.schedule(apply_theme)
end)

-- 4. Apply the theme once on startup as well.
apply_theme()
