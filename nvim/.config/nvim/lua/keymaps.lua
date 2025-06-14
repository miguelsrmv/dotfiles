-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[Custom Commands]]
-- Keybinds to make navigating between buffers and tabs easier
vim.keymap.set('n', ']b', ':bnext<CR>', { silent = true }) -- Next buffer
vim.keymap.set('n', '[b', ':bprevious<CR>', { silent = true }) -- Previous buffer
vim.keymap.set('n', ']B', ':blast<CR>', { silent = true }) -- Last buffer
vim.keymap.set('n', '[B', ':bfirst<CR>', { silent = true }) -- First buffer

vim.keymap.set('n', ']t', ':tabnext<CR>', { silent = true }) -- Next tab
vim.keymap.set('n', '[t', ':tabprevious<CR>', { silent = true }) -- Previous tab
vim.keymap.set('n', ']T', ':tablast<CR>', { silent = true }) -- Last tab
vim.keymap.set('n', '[T', ':tabfirst<CR>', { silent = true }) -- First tab

-- Direct tab access with :T{number}
vim.cmd 'command! -nargs=1 T tabnext <args>'
vim.cmd 'command! -nargs=1 B buffernext <args>'

-- Split windows horizontally or vertically
vim.keymap.set('n', '<leader>wh', ':split<CR>', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>wv', ':vsplit<CR>', { desc = 'Split window vertically' })

-- AI-powered Keymaps
vim.keymap.set('n', '<leader>apc', function()
  vim.cmd ':Git add .'
  vim.cmd ':Git commit --verbose'
  vim.cmd ":AvanteAsk 'Generate a concise commit message following Conventional Commits format (type(scope): description). Analyze the changes to identify the primary purpose (feat, fix, docs, style, refactor, perf, test, chore). Include relevant ticket numbers if pattern [ABC-123] is found in branch name. Keep the first line under 72 characters.'"
end, { desc = 'avante: generate commit message' })

vim.keymap.set('n', '<leader>apd', function()
  vim.cmd ":AvanteAsk 'Add comprehensive Doxygen documentation to this file. Include: @brief descriptions, @param details with types and purpose, @return values, @throws exceptions, @note for important considerations, and @example where helpful. Maintain existing documentation style if present. Focus on public APIs first.'"
end, { desc = 'avante: generate complete documentation' })

vim.keymap.set({ 'v', 'x' }, '<leader>apd', function()
  vim.cmd ":AvanteAsk 'Add comprehensive Doxygen documentation to this code. Include: @brief descriptions, @param details with types and purpose, @return values, @throws exceptions, @note for important considerations, and @example where helpful. Maintain existing documentation style if present. Focus on public APIs first.'"
end, { desc = 'avante: generate complete documentation' })

vim.keymap.set({ 'v', 'x' }, '<leader>apo', function()
  vim.cmd ":AvanteAsk 'Optimize this code for: 1) Performance - reduce time/space complexity, 2) Readability - improve naming and structure, 3) Maintainability - reduce duplications and follow best practices. Explain key optimizations and preserve original functionality.'"
end, { desc = 'avante: optimize selected code' })

vim.keymap.set({ 'v', 'x' }, '<leader>apt', function()
  vim.cmd ":AvanteAsk 'Create comprehensive unit tests for this code. Include: 1) Happy path tests, 2) Edge cases and error conditions, 3) Boundary values, 4) Appropriate mocks/stubs where needed. Use testing framework patterns appropriate for the language. Organize tests logically with descriptive names.'"
end, { desc = 'avante: create thorough unit tests' })

vim.keymap.set({ 'v', 'x' }, '<leader>apr', function()
  vim.cmd ":AvanteAsk 'Review this code for: 1) Potential bugs/errors, 2) Security vulnerabilities, 3) Performance issues, 4) Maintainability concerns, 5) Adherence to language best practices, 6) Edge cases not handled. Prioritize critical issues first and suggest specific improvements.'"
end, { desc = 'avante: perform detailed code review' })

vim.keymap.set({ 'v', 'x' }, '<leader>apx', function()
  vim.cmd ":AvanteAsk 'Explain this code in detail: 1) Overall purpose, 2) How it works step-by-step, 3) Key algorithms or patterns used, 4) Potential edge cases or limitations, 5) Performance characteristics. Adjust explanation depth based on complexity. Include relevant programming concepts where helpful.'"
end, { desc = 'avante: explain code comprehensively' })

vim.keymap.set({ 'v', 'x' }, '<leader>apb', function()
  vim.cmd ":AvanteAsk 'Debug this code. Identify potential issues, suggest fixes, and explain the root causes of any bugs. Consider edge cases and runtime errors.'"
end, { desc = 'avante: debug code' })

-- vim: ts=2 sts=2 sw=2 et
